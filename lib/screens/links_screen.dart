import 'package:flutter/material.dart';
import 'package:ikus_app/components/buttons/ovgu_button.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/link_group.dart';
import 'package:ikus_app/service/link_service.dart';
import 'package:ikus_app/utility/adaptive.dart';
import 'package:ikus_app/utility/ui.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    List<LinkGroup> links = LinkService.getLinks();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: OvguColor.primary,
        title: Text(t.links.title)
      ),
      body: ListView(
        physics: Adaptive.getScrollPhysics(),
        children: [
          ...links.map((group) => Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: OvguPixels.mainScreenPadding,
                  child: Text(group.name, style: TextStyle(color: OvguColor.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: group.links.map((link) => Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.arrow_right),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(link.info, style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(link.urlNoHttp, style: TextStyle())
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: OvguButton(
                            callback: () async {
                              await launch(link.url);
                            },
                            child: Icon(Icons.arrow_forward, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 20)
                      ],
                    ),
                  )).toList(),
                )
              ],
            ),
          )).toList(),
          SizedBox(height: 50)
        ],
      ),
    );
  }
}
