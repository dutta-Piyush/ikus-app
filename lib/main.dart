import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/screens/main_screen.dart';
import 'package:ikus_app/service/orientation_service.dart';
import 'package:ikus_app/service/syncable_service.dart';
import 'package:ikus_app/utility/adaptive.dart';
import 'package:ikus_app/utility/globals.dart';
import 'package:ikus_app/utility/ui.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {

  // load cache
  await Hive.initFlutter();
  await Hive.openBox<DateTime>('last_sync');
  await Hive.openBox<String>('api_json');
  await Hive.openBox<Uint8List>('api_binary');
  List<SyncableService> services = SyncableService.services;
  for(SyncableService service in services) {
    await service.sync(useCache: true);
  }

  // initialize other stuff
  await LocaleSettings.useDeviceLocale();
  await initializeDateFormatting();

  runApp(IkusApp());
}

class IkusApp extends StatefulWidget {
  @override
  IkusAppState createState() => IkusAppState();
}

class IkusAppState extends State<IkusApp> {

  final NavigatorObserver _navObserver = NavigatorObserverWithOrientation();

  @override
  void initState() {
    super.initState();
    Globals.ikusAppState = this;
  }

  void setLocale(String locale) {
    setState(() {
      LocaleSettings.setLocale(locale);
    });
  }

  @override
  Widget build(BuildContext context) {

    precacheImage(AssetImage("assets/img/maps/campus-main.jpg"), context);
    precacheImage(AssetImage("assets/img/maps/campus-med.jpg"), context);

    return MaterialApp(
      title: 'IKUS',
      debugShowCheckedModeBanner: false,
      builder: Adaptive.getBehaviour(),
      theme: ThemeData(
        primaryColor: OvguColor.primary,
        accentColor: OvguColor.secondary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      navigatorObservers: [ _navObserver ],
    );
  }
}
