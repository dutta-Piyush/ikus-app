import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarColor extends StatelessWidget {

  final Widget child;
  final Brightness brightness;

  const StatusBarColor({@required this.child, @required this.brightness});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarBrightness: brightness),
      child: child,
    );
  }
}
