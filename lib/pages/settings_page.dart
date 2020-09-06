import 'package:flutter/material.dart';
import 'package:ikus_app/components/buttons/ovgu_button.dart';
import 'package:ikus_app/components/cards/ovgu_card.dart';
import 'package:ikus_app/components/icon_text.dart';
import 'package:ikus_app/components/main_list_view.dart';
import 'package:ikus_app/components/rotating.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/screens/about_screen.dart';
import 'package:ikus_app/service/post_service.dart';
import 'package:ikus_app/utility/callbacks.dart';
import 'package:ikus_app/utility/globals.dart';
import 'package:ikus_app/utility/ui.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  static const Color LOGO_COLOR = Color(0xFFAFAFAF);
  String _version = '';

  Map<String, bool> syncing = Map();

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() {
        _version = info.version+' ('+info.buildNumber+')';
      });
    });
  }

  Widget getSettingsItem({@required String left, @required Widget right}) {
    return Row(
      children: [
        Expanded(
            child: Text(left, style: TextStyle(fontSize: 16))
        ),
        right
      ],
    );
  }

  Widget getSyncItem(String name, FutureCallback callback) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('24.08.2020, 13:32')
                ],
              )
          ),
          OvguButton(
            useIconWidth: true,
            flat: true,
            callback: () async {
              setState(() {
                syncing[name] = true;
              });
              await callback();
              setState(() {
                syncing[name] = false;
              });
            },
            child: syncing[name] == true ? Rotating(child: Icon(Icons.sync)) : Icon(Icons.sync),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainListView(
        padding: OvguPixels.mainScreenPadding,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          IconText(
            size: OvguPixels.headerSize,
            distance: OvguPixels.headerDistance,
            icon: Icons.settings,
            text: t.main.settings.title,
          ),
          SizedBox(height: 20),
          getSettingsItem(
              left: t.main.settings.language,
              right: Row(
                children: [
                  RaisedButton(
                    color: LocaleSettings.currentLocale == 'en' ? OvguColor.primary : OvguColor.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(15))
                    ),
                    onPressed: () {
                      setState(() {
                        Globals.ikusAppState.setLocale('en');
                      });
                    },
                    child: Text('EN', style: TextStyle(color: LocaleSettings.currentLocale == 'en' ? Colors.white : Colors.black)),
                  ),
                  RaisedButton(
                    color: LocaleSettings.currentLocale == 'de' ? OvguColor.primary : OvguColor.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(15))
                    ),
                    onPressed: () {
                      setState(() {
                        Globals.ikusAppState.setLocale('de');
                      });
                    },
                    child: Text('DE', style: TextStyle(color: LocaleSettings.currentLocale == 'de' ? Colors.white : Colors.black)),
                  )
                ],
              )
          ),
          SizedBox(height: 20),
          OvguCard(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.main.settings.sync, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(t.main.settings.syncInfo),
                  SizedBox(height: 5),
                  getSyncItem(t.main.settings.syncItems.news, () async {
                    await PostService.sync();
                  }),
                  getSyncItem(t.main.settings.syncItems.calendar, () {
                    return Future.value();
                  }),
                  getSyncItem(t.main.settings.syncItems.mensa, () {
                    return Future.value();
                  }),
                  getSyncItem(t.main.settings.syncItems.links, () {
                    return Future.value();
                  }),
                  getSyncItem(t.main.settings.syncItems.handbook, () {
                    return Future.value();
                  }),
                  getSyncItem(t.main.settings.syncItems.faq, () {
                    return Future.value();
                  }),
                  getSyncItem(t.main.settings.syncItems.contact, () {
                    return Future.value();
                  })
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          getSettingsItem(
              left: t.main.settings.reset,
              right: OvguButton(
                useIconWidth: true,
                callback: () {

                },
                child: Icon(Icons.restore, color: Colors.white),
              )
          ),
          SizedBox(height: 20),
          getSettingsItem(
              left: t.main.settings.licenses,
              right: OvguButton(
                useIconWidth: true,
                callback: () {
                  pushScreen(context, () => LicensePage(applicationName: 'IKUS App', applicationVersion: _version));
                },
                child: Icon(Icons.description, color: Colors.white),
              )
          ),
          SizedBox(height: 20),
          getSettingsItem(
              left: t.main.settings.about,
              right: OvguButton(
                useIconWidth: true,
                callback: () {
                  pushScreen(context, () => AboutScreen());
                },
                child: Icon(Icons.info, color: Colors.white),
              )
          ),
          SizedBox(height: 50),
          Opacity(
            opacity: 0.3,
            child: Image.asset('assets/img/logo-512-alpha.png', width: 200)
          ),
          SizedBox(height: 10),
          Text(t.main.settings.theIkusApp, style: TextStyle(color: LOGO_COLOR, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3)),
          SizedBox(height: 10),
          Text('Version $_version', style: TextStyle(color: LOGO_COLOR, fontSize: 14)),
          SizedBox(height: 5),
          Text('© 2020 OVGU', style: TextStyle(color: LOGO_COLOR, fontSize: 14)),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
