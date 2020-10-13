import 'package:flutter/material.dart';
import 'package:ikus_app/components/buttons/ovgu_button.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/utility/ui.dart';

class GenericConfirmPopup extends StatelessWidget {

  final String title;
  final String info;
  final List<Widget> buttons;

  const GenericConfirmPopup({@required this.title, @required this.info, @required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
      child: Column(
          children: [
            Center(
              child: Text(title, style: TextStyle(color: OvguColor.primary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(child: Text(info, style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
                  if (buttons.length == 1)
                    Center(
                      child: OvguButton(
                        callback: () {
                          Navigator.pop(context);
                        },
                        child: Text(t.popups.eventPastPopup.ok, style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  if (buttons.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: buttons
                    )
                ],
              ),
            ),
          ]
      ),
    );
  }
}
