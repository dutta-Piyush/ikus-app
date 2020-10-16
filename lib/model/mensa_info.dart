import 'package:flutter/foundation.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/menu.dart';
import "package:latlong/latlong.dart";

enum Mensa {
  UNI_CAMPUS_DOWN,
  UNI_CAMPUS_UP,
  ZSCHOKKE,
  HERRENKRUG
}

class MensaInfo {
  final Mensa name;
  final String openingHours;
  final LatLng coords;
  final List<Menu> menus;

  MensaInfo({@required this.name, @required this.openingHours, @required this.coords, @required this.menus});

  static MensaInfo fromMap(Map<String, dynamic> map) {
    return MensaInfo(
        name: (map['name'] as String).toMensa(),
        openingHours: map['openingHours'],
        coords: map['coords'] != null ? LatLng(map['coords']['x'], map['coords']['y']) : null,
        menus: map['menus']
            .map((menu) => Menu.fromMap(menu))
            .toList()
            .cast<Menu>()
    );
  }

  @override
  String toString() {
    return '$name [$menus]';
  }
}

extension MensaLocationMembers on Mensa {
  String get name => {
    Mensa.UNI_CAMPUS_DOWN: t.mensa.locations.uniCampusDown,
    Mensa.UNI_CAMPUS_UP: t.mensa.locations.uniCampusUp,
    Mensa.ZSCHOKKE: t.mensa.locations.zschokke,
    Mensa.HERRENKRUG: t.mensa.locations.herrenkrug
  }[this];
}

extension MensaLocationParser on String {
  Mensa toMensa() {
    return Mensa.values.firstWhere((element) => describeEnum(element) == this, orElse: () => null);
  }
}