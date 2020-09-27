import 'dart:convert';

import 'package:http/http.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/channel.dart';
import 'package:ikus_app/model/link.dart';
import 'package:ikus_app/model/link_group.dart';
import 'package:ikus_app/service/api_service.dart';
import 'package:ikus_app/service/syncable_service.dart';

class LinkService implements SyncableService {

  static final LinkService _instance = _init();
  static LinkService get instance => _instance;

  DateTime _lastUpdate;
  List<LinkGroup> _links;

  static LinkService _init() {
    LinkService service = LinkService();

    service._links = [
      LinkGroup(
        channel: Channel(name: "Studieren"),
        links: [
          Link(url: "https://www.ovgu.de", info: "Die Uni-Homepage"),
          Link(url: "https://lsf.ovgu.de", info: "Studentenportal"),
          Link(url: "https://myovgu.ovgu.de", info: "MyOvgu Portal"),
          Link(url: "https://webmailer.ovgu.de", info: "E-Mail Postfach"),
          Link(url: "https://elearning.ovgu.de", info: "Das Moodle-Portal"),
          Link(url: "https://www.studentenwerk-magdeburg.de", info: "Studentenwerk"),
          Link(url: "http://www.servicecenter.ovgu.de/", info: "Campus Service Center")
        ]
      ),
      LinkGroup(
        channel: Channel(name: "Leben"),
        links: [
          Link(url: "https://bahn.de", info: "Deutsche Bahn"),
          Link(url: "https://www.unifilm.de/studentenkinos/MD_HiD", info: "Hörsaal im Dunkeln (HiD)")
        ]
      ),
      LinkGroup(
        channel: Channel(name: "Arbeit"),
        links: [
          Link(url: "https://ovgu.jobteaser.com", info: "JobTeaser")
        ]
      )
    ];

    service._lastUpdate = DateTime(2020, 8, 24, 13, 12);
    return service;
  }

  @override
  String getName() => t.main.settings.syncItems.links;

  @override
  Future<void> sync() async {
    Response response = await ApiService.getCacheOrFetch('links', LocaleSettings.currentLocale);
    List<dynamic> list = jsonDecode(response.body);
    _links = list.map((group) => LinkGroup.fromMap(group)).toList();
    _lastUpdate = DateTime.now();
  }

  @override
  DateTime getLastUpdate() {
    return _lastUpdate;
  }

  List<LinkGroup> getLinks() {
    return _links;
  }
}