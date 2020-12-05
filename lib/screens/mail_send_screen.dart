import 'package:flutter/material.dart';
import 'package:ikus_app/components/buttons/ovgu_button.dart';
import 'package:ikus_app/components/cards/ovgu_card.dart';
import 'package:ikus_app/components/inputs/ovgu_text_area.dart';
import 'package:ikus_app/components/inputs/ovgu_text_field.dart';
import 'package:ikus_app/components/main_list_view.dart';
import 'package:ikus_app/components/popups/error_popup.dart';
import 'package:ikus_app/components/popups/generic_text_popup.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/mail_message_send.dart';
import 'package:ikus_app/model/ovgu_account.dart';
import 'package:ikus_app/service/mail_service.dart';
import 'package:ikus_app/service/settings_service.dart';
import 'package:ikus_app/utility/callbacks.dart';
import 'package:ikus_app/utility/globals.dart';
import 'package:ikus_app/utility/ui.dart';

class MailSendScreen extends StatefulWidget {

  final Callback onSend;

  const MailSendScreen({this.onSend});

  @override
  _MailSendScreenState createState() => _MailSendScreenState();
}

class _MailSendScreenState extends State<MailSendScreen> {

  final _fromController = TextEditingController();
  OvguAccount _ovguAccount;
  String _from = '';
  String _to = '';
  List<String> _cc = [];
  String _subject = '';
  String _content = '';

  @override
  void initState() {
    super.initState();
    _ovguAccount = SettingsService.instance.getOvguAccount();
    if (_ovguAccount.mailAddress != null) {
      _from = _ovguAccount.mailAddress;
      _fromController.text = _from;
    }
  }

  Future<void> send() async {

    if (_from.isEmpty) {
      ErrorPopup.open(context, message: t.mailMessageSend.errors.missingFrom);
      return;
    }

    if (_to.isEmpty) {
      ErrorPopup.open(context, message: t.mailMessageSend.errors.missingTo);
      return;
    }

    if (_subject.isEmpty) {
      ErrorPopup.open(context, message: t.mailMessageSend.errors.missingSubject);
      return;
    }

    if (_content.isEmpty) {
      ErrorPopup.open(context, message: t.mailMessageSend.errors.missingContent);
      return;
    }

    // save mail address to settings
    SettingsService.instance.setOvguAccount(
        name: _ovguAccount.name,
        password: _ovguAccount.password,
        mailAddress: _from
    );

    DateTime start = DateTime.now();
    GenericTextPopup.open(context: context, text: t.mailMessageSend.sending);

    final message = MailMessageSend(from: _from, to: _to, cc: _cc, subject: _subject, content: _content);
    bool result = await MailService.instance.sendMessage(message);

    // at least 1sec popup time
    await sleepRemaining(1000, start);
    Navigator.pop(context);

    if (result) {
      Navigator.pop(context);
      if (widget.onSend != null) {
        widget.onSend();
      }
    } else {
      ErrorPopup.open(context);
    }
  }

  void addCC() {
    setState(() {
      _cc = [ ..._cc, '' ];
    });
  }

  void removeCC() {
    setState(() {
      _cc.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OvguColor.primary,
        title: Text(t.mailMessageSend.title),
      ),
      body: MainListView(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(15),
            child: OvguCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.mailMessageSend.from),
                    SizedBox(height: 5),
                    OvguTextField(
                      controller: _fromController,
                      hint: t.mailMessageSend.from,
                      icon: Icons.person,
                      type: TextFieldType.CLEAR,
                      onChange: (value) {
                        setState(() {
                          _from = value;
                        });
                      }
                    ),
                    SizedBox(height: 15),
                    Text(t.mailMessageSend.to),
                    SizedBox(height: 5),
                    OvguTextField(
                      hint: t.mailMessageSend.to,
                      icon: Icons.person,
                      type: TextFieldType.CLEAR,
                      onChange: (value) {
                        setState(() {
                          _to = value;
                        });
                      }
                    ),
                    SizedBox(height: 15),
                    ...List.generate(_cc.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: OvguTextField(
                          hint: t.mailMessageSend.cc,
                          icon: Icons.people,
                          type: TextFieldType.CLEAR,
                          onChange: (value) {
                            setState(() {
                              _cc[index] = value;
                            });
                          }
                        ),
                      );
                    }),
                    Row(
                      children: [
                        OvguButton(
                            callback: addCC,
                            child: Icon(Icons.person_add, color: Colors.white)
                        ),
                        SizedBox(width: 15),
                        OvguButton(
                          callback: _cc.isNotEmpty ? removeCC : null,
                          child: Icon(Icons.person_remove, color: Colors.white)
                        )
                      ],
                    )
                  ],
                ),
              )
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: OvguTextField(
                hint: t.mailMessageSend.subject,
                icon: Icons.subject,
                type: TextFieldType.CLEAR,
                onChange: (value) {
                  setState(() {
                    _subject = value;
                  });
                }
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: OvguTextArea(
                hint: t.mailMessageSend.content,
                minLines: 10,
                maxLines: 20,
                onChange: (value) {
                  setState(() {
                    _content = value;
                  });
                }
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: Align(
              alignment: Alignment.centerRight,
              child: UnconstrainedBox(
                child: OvguButton(
                  callback: send,
                  child: Row(
                    children: [
                      Text(t.mailMessageSend.send, style: TextStyle(color: Colors.white)),
                      SizedBox(width: 10),
                      Icon(Icons.send, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 50)
        ],
      ),
    );
  }
}
