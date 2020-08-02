import 'package:flutter/material.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/screens/main_screen.dart';
import 'package:ikus_app/utility/globals.dart';
import 'package:ikus_app/utility/ui.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(IkusApp()));
}

class IkusApp extends StatefulWidget {
  @override
  IkusAppState createState() => IkusAppState();
}

class IkusAppState extends State<IkusApp> {

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    LocaleSettings.useDeviceLocale().whenComplete(() {
      setState((){
        _initialized = true;
      });
    });

    Globals.ikusAppState = this;
  }

  void setLocale(String locale) {
    setState(() {
      LocaleSettings.setLocale(locale);
    });
  }

  @override
  Widget build(BuildContext context) {

    if (!_initialized)
      return Container(color: Colors.white);

    return MaterialApp(
      title: 'IKUS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: OvguColor.primary,
        accentColor: OvguColor.secondary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}
