import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ikus_app/components/buttons/ovgu_button.dart';
import 'package:ikus_app/components/popups/handbook_popup.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/pdf_bookmark.dart';
import 'package:ikus_app/service/handbook_service.dart';
import 'package:ikus_app/utility/globals.dart';
import 'package:ikus_app/utility/popups.dart';
import 'package:ikus_app/utility/ui.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:url_launcher/url_launcher.dart';

class HandbookScreen extends StatefulWidget {
  @override
  _HandbookScreenState createState() => _HandbookScreenState();
}

class _HandbookScreenState extends State<HandbookScreen> {

  PdfController pdfController;

  @override
  void initState() {
    super.initState();
    Uint8List pdf = HandbookService.instance.getPDF();
    if (pdf.isNotEmpty)
      pdfController = PdfController(document: PdfDocument.openData(pdf));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OvguColor.primary,
        title: Text(t.handbook.title)
      ),
      body: Stack(
        children: [
          if (pdfController == null)
            Center(
              child: Container(
                child: Text(t.handbook.wip, style: TextStyle(color: OvguColor.secondaryDarken2, fontSize: 20)),
              ),
            ),
          if (pdfController != null)
            PdfView(
              controller: pdfController,
              scrollDirection: Axis.vertical,
            ),
          if (pdfController != null)
            Positioned(
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  OvguButton(
                    callback: () {
                      List<PdfBookmark> bookmarks = HandbookService.instance.getBookmarks();
                      double height = MediaQuery.of(context).size.height;
                      Popups.generic(
                          context: context,
                          height: min(height - 300, 500),
                          body: HandbookPopup(
                            bookmarks: bookmarks,
                            callback: (page) async {
                              Navigator.pop(context);
                              await sleep(300);
                              pdfController.animateToPage(page,
                                duration: Duration(milliseconds: 1000),
                                curve: Curves.easeInOutCubic
                              );
                            },
                          )
                      );
                    },
                    child: Icon(Icons.list, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  OvguButton(
                    callback: () async {
                      await launch(HandbookService.instance.getHandbookUrl(LocaleSettings.currentLocale, true));
                    },
                    child: Icon(Icons.cloud_download, color: Colors.white),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
