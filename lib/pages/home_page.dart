import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikus_app/components/event_card.dart';
import 'package:ikus_app/components/icon_text.dart';
import 'package:ikus_app/components/favorite_button.dart';
import 'package:ikus_app/components/post_card.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/event.dart';
import 'package:ikus_app/model/post.dart';
import 'package:ikus_app/screens/events_screen.dart';
import 'package:ikus_app/screens/map_screen.dart';
import 'package:ikus_app/screens/mensa_screen.dart';
import 'package:ikus_app/utility/extensions.dart';
import 'package:ikus_app/utility/ui.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const List<Event> EVENTS = [
    Event("Immatrikulationsfeier", "15.10.2020, 19 Uhr", "Festung Mark"),
    Event("Wohnheim-Spieleabend", "23.10.2020, 20 Uhr", "Campus Theater"),
    Event("Grillen", "17.10.2020, 16 Uhr", "vor Gebäude 16")
  ];

  static List<Post> POSTS = [
    Post("Dr.-Ing Jens Strackeljan als Rektor gewählt", "Prof. Dr.-Ing. Jens Strackeljan wurde als Rektor der Otto-von-Guericke-Universität Magdeburg im Amt wiedergewählt. Am 15. Juli 2020 hat der erweiterte Senat, das höchste Gremium der Universität,", "IKUS", "15.07.2020", Image.asset('assets/img/logo-512-alpha.png')),
    Post("Dr.-Ing Jens Strackeljan als Rektor gewählt", "Prof. Dr.-Ing. Jens Strackeljan wurde als Rektor der Otto-von-Guericke-Universität Magdeburg im Amt wiedergewählt. Am 15. Juli 2020 hat der erweiterte Senat, das höchste Gremium der Universität,", "Wohnheim", "15.07.2020", null),
    Post("Dr.-Ing Jens Strackeljan als Rektor gewählt", "Prof. Dr.-Ing. Jens Strackeljan wurde als Rektor der Otto-von-Guericke-Universität Magdeburg im Amt wiedergewählt. Am 15. Juli 2020 hat der erweiterte Senat, das höchste Gremium der Universität,", "AKAA", "15.07.2020", Image.asset('assets/img/logo-512-alpha.png')),
    Post("Dr.-Ing Jens Strackeljan als Rektor gewählt", "Prof. Dr.-Ing. Jens Strackeljan wurde als Rektor der Otto-von-Guericke-Universität Magdeburg im Amt wiedergewählt. Am 15. Juli 2020 hat der erweiterte Senat, das höchste Gremium der Universität,", "Wohnheim", "15.07.2020", null)
  ];

  int _currentEventIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FavoriteButton(icon: Icons.map, text: t.main.catalog.content.map, callback: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => MapScreen()));
                  }),
                  FavoriteButton(icon: Icons.restaurant, text: t.main.catalog.content.mensa, callback: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => MensaScreen()));
                  }),
                  FavoriteButton(icon: Icons.calendar_today, text: t.main.catalog.content.events, callback: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => EventsScreen()));
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: IconText(
              size: OvguPixels.headerSize,
              distance: OvguPixels.headerDistance,
              icon: Icons.today,
              text: t.main.home.nextEvents,
            ),
          ),
          SizedBox(height: 20),
          CarouselSlider(
            options: CarouselOptions(
              height: 100,
              viewportFraction: 1,
              autoPlay: true,
              onPageChanged: (index, _) {
                setState(() {
                  _currentEventIndex = index;
                });
              }
            ),
            items: EVENTS.map((event) {
              return Builder(
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: EventCard(event: event),
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: EVENTS.mapIndexed((event, index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentEventIndex == index
                    ? Color.fromRGBO(0, 0, 0, 0.9)
                    : Color.fromRGBO(0, 0, 0, 0.4)),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: IconText(
              size: OvguPixels.headerSize,
              distance: OvguPixels.headerDistance,
              icon: Icons.announcement,
              text: t.main.home.news,
            ),
          ),
          SizedBox(height: 20),
          ...POSTS.map((post) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: PostCard(post: post),
          )),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
