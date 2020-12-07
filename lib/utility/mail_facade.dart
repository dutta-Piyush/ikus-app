import 'dart:developer';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ikus_app/model/mail_message.dart';
import 'package:ikus_app/model/mail_message_send.dart';
import 'package:ikus_app/model/mailbox_type.dart';
import 'package:ikus_app/service/api_service.dart';
import 'package:ikus_app/utility/callbacks.dart';

enum PartType {
  MULTIPART, PLAIN, HTML, OTHER
}

class PartMetadata {
  final String path;
  final PartType type;
  final String encoding; // nullable
  final String charset; // nullable

  PartMetadata(this.path, this.type, this.encoding, this.charset);
}

class MailFacade {

  static const String LOG_NAME = 'Mail';
  static const Duration MAILS_YOUNGER_THAN = Duration(days: 90);
  static const String MAILBOX_PATH_INBOX = "INBOX";
  static const String MAILBOX_PATH_SEND = "INBOX.Sent";

  static Future<bool> testLogin({@required String name, @required String password}) async {
    try {
      final client = ImapClient();
      await client.connectToServer('cyrus.ovgu.de', 993);
      final response = await client.login(name, password);
      final ok = response.isOkStatus;
      await client.closeConnection();
      return ok;
    } catch (e) {
      log(e.toString(), error: e, name: LOG_NAME);
      return false;
    }
  }

  /// Fetches mails younger than [MAILS_YOUNGER_THAN].
  /// Use existing mails to reduce fetch amount
  static Future<Map<int, MailMessage>> fetchMessages({@required MailboxType mailbox, @required String name, @required String password, @required Map<int, MailMessage> existing, MailProgressCallback progressCallback}) async {
    try {
      final imapClient = await getImapClient(name: name, password: password);
      if (imapClient == null)
        return null;

      final selectInboxResponse = await imapClient.selectMailboxByPath(mailbox.path);
      if (selectInboxResponse.isFailedStatus)
        return null;

      final ids = await imapClient.uidSearchMessages('YOUNGER ${MAILS_YOUNGER_THAN.inSeconds}');

      if (ids.isFailedStatus)
        return null;

      final fetchSequence = MessageSequence();
      final resultMap = Map<int, MailMessage>();
      ids.result.ids.forEach((id) {
        MailMessage message = existing[id];
        if (message != null)
          resultMap[id] = message; // add existing message
        else
          fetchSequence.add(id); // add to fetch list (will be fetched in the next step)
      });

      log(' -> Provided ${existing.length} cached mails, need to fetch ${fetchSequence.length}.', name: LOG_NAME);

      if (fetchSequence.isEmpty()) {
        return resultMap; // all mails has already been fetched (no new mails)
      }

      final fetchIdMap = Map<int, List<PartMetadata>>();
      final fetchResponse = await imapClient.uidFetchMessages(fetchSequence, '(BODYSTRUCTURE)');
      if (fetchResponse.isFailedStatus)
        return null;

      fetchResponse.result.messages.forEach((m) {
        if (m.body.parts == null) {
          final type = getPartType(m.mediaType.sub);
          final encoding = m.body.encoding;
          final charset = m.body.contentType.charset;
          fetchIdMap[m.uid] = [PartMetadata("1", type, encoding, charset)];
        } else {
          List<PartMetadata> list = List();
          _addTextParts(m.body.parts, list);
          fetchIdMap[m.uid] = list;
        }
      });

      int curr = 0;
      int errors = 0;
      for (final mail in fetchIdMap.entries) {
        try {
          if (progressCallback != null) {
            curr++;
            progressCallback(curr, fetchIdMap.length);
          }

          final uid = mail.key;
          final partMetadata = mail.value;
          final fetchSequence = MessageSequence()..add(uid);
          final bodies = mail.value.map((part) => 'BODY[${part.path}]').join(' ');
          final res = await imapClient.uidFetchMessages(fetchSequence, '(ENVELOPE $bodies)');
          if (res.isFailedStatus)
            return null;

          final mailResponse = res.result.messages.first;
          final PartMetadata htmlPart = partMetadata.firstWhere((part) => part.type == PartType.HTML, orElse: () => null);
          final PartMetadata plainPart = partMetadata.firstWhere((part) => part.type == PartType.PLAIN, orElse: () => null);
          String plain;
          String html;

          if (plainPart != null) {
            plain = mailResponse.getPart(plainPart.path)?.bodyRaw;

            // workaround: skip decoding for 8bit/windows-1252
            if (plainPart.encoding != '8bit' || plainPart.charset != 'windows-1252') {
              plain = MailCodec.decodeAnyText(plain, plainPart.encoding, plainPart.charset);
            }
          }

          if (htmlPart != null) {
            html = mailResponse.getPart(htmlPart.path)?.bodyRaw;

            // workaround: skip decoding for 8bit/windows-1252
            if (htmlPart.encoding != '8bit' || htmlPart.charset != 'windows-1252') {
              html = MailCodec.decodeAnyText(html, htmlPart.encoding, htmlPart.charset);
            }
          }

          List<String> toList = mailResponse.to.map((m) => m.email).toList();
          String to = toList.firstWhere((t) => true, orElse: () => 'unknown');
          List<String> cc = mailResponse.cc.map((m) => m.email).toList();
          if (toList.length > 1) {
            cc = [...toList.sublist(1), ...cc];
          }

          resultMap[uid] = MailMessage(
            uid: uid,
            from: mailResponse.fromEmail ?? 'unknown',
            to: to,
            cc: cc,
            timestamp: mailResponse.decodeDate()?.toLocal() ?? ApiService.FALLBACK_TIME,
            subject: mailResponse.decodeSubject(),
            contentPlain: plain,
            contentHtml: html
          );

        } catch (e) {
          errors++;
          log(e.toString(), error: e, name: LOG_NAME);
        }
      }

      try {
        await imapClient.closeConnection();
      } catch (e) {
        log(' -> IMAP logout failed', name: LOG_NAME);
      }

      log(' -> Fetched ($errors errors / ${fetchIdMap.length} total)', name: LOG_NAME);

      return resultMap;
    } catch (e) {
      log(e.toString(), error: e, name: LOG_NAME);
      return null;
    }
  }

  static Future<bool> deleteMessage({@required MailboxType mailbox, @required int uid, @required String name, @required String password}) async {
    final imapClient = await getImapClient(name: name, password: password);
    if (imapClient == null)
      return false;

    final selectInboxResponse = await imapClient.selectMailboxByPath(mailbox.path);
    if (selectInboxResponse.isFailedStatus)
      return null;

    final uidSequence = MessageSequence()..add(uid);
    final markResponse = await imapClient.uidMarkDeleted(uidSequence);
    if (markResponse.isFailedStatus)
      return false;

    final deleteResponse = await imapClient.expunge();
    if (deleteResponse.isFailedStatus)
      return false;

    await imapClient.closeConnection();

    return true;
  }

  static Future<bool> sendMessage(MailMessageSend message, {@required String name, @required String password}) async {

    try {
      final client = SmtpClient('ovgu.de');
      await client.connectToServer('mail.ovgu.de', 587, isSecure: false);
      final ehloResponse = await client.ehlo();
      if (ehloResponse.isFailedStatus) {
        return false;
      }

      final tlsResponse = await client.startTls();
      if (tlsResponse.isFailedStatus)
        return false;

      final loginResponse = await client.login(name, password);
      if (loginResponse.isFailedStatus)
        return false;

      final sendResponse = await client.sendMessage(message.toMimeMessage());
      if (sendResponse.isFailedStatus)
        return false;

      await client.closeConnection();

      // add email to sent folder
      final imapClient = await getImapClient(name: name, password: password);
      if (imapClient == null)
        return false;
      await imapClient.appendMessage(message.toMimeMessage(), targetMailboxPath: MAILBOX_PATH_SEND);
      await imapClient.closeConnection();

      return true;
    } catch (e) {
      log(e.toString(), error: e, name: LOG_NAME);
      return false;
    }
  }

  // for enough_mail (not using yet)
  static void _addTextParts(List<BodyPart> parts, List<PartMetadata> result) {
    parts.forEach((part) {
      if (part.contentType.mediaType.isText) {
        final path = part.fetchId;
        final type = getPartType(part.contentType.mediaType.sub);
        final encoding = part.encoding;
        final charset = part.contentType.charset;
        result.add(PartMetadata(path, type, encoding, charset));
      } else if (part.parts != null) {
        _addTextParts(part.parts, result);
      }
    });
  }

  static PartType getPartType(MediaSubtype type) {
    switch (type) {
      case MediaSubtype.textPlain: return PartType.PLAIN;
      case MediaSubtype.textHtml: return PartType.HTML;
      default: return PartType.OTHER;
    }
  }

  static Future<ImapClient> getImapClient({@required String name, @required String password}) async {
    final imapClient = ImapClient();
    await imapClient.connectToServer('cyrus.ovgu.de', 993);
    final response = await imapClient.login(name, password);
    if (response.isFailedStatus)
      return null;

    return imapClient;
  }
}