import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/food.dart';
import 'package:ikus_app/model/menu.dart';
import 'package:ikus_app/service/syncable_service.dart';
import 'package:ikus_app/utility/globals.dart';

class MensaService implements SyncableService {

  static final MensaService _instance = _init();
  static MensaService get instance => _instance;

  DateTime _lastUpdate;
  List<Menu> _menu;

  static MensaService _init() {
    MensaService service = MensaService();

    service._menu = [
      Menu(MensaLocation.UNI_CAMPUS_DOWN, DateTime(2020,8,12), [
        Food('Magde-Burger mit panierter Jagdwurstscheibe, Letscho, Weißkraut und Röstzwiebeln dazu Kartoffelspalten und Kräuterquark', 2.8, [FoodTag.PIG]),
        Food('Paniertes Rotbarschfilet mit Remouladensoße dazu eine Gemüsebeilage und eine Sättigungsbeilage zur Auswahl', 2.6, [FoodTag.FISH]),
        Food('2 Sesam-Karotten-Knuspersticks mit Limetten-Ingwersoße dazu eine Gemüsebeilage und eine Sättigungsbeilage zur Auswahl', 2.6, [FoodTag.VEGAN])
      ]
      ),
      Menu(MensaLocation.UNI_CAMPUS_UP, DateTime(2020,8,12), [
        Food('Feuriges Gemüse-Rindfleisch-Curry mit Mienudeln ', 2.3, [FoodTag.BEEF, FoodTag.GARLIC]),
        Food('Schweinesteak Förster Art mit Waldpilzsoße dazu eine Gemüsebeilage und eine Sättigungsbeilage zur Auswahl', 2.6, [FoodTag.PIG]),
        Food('5 Kartoffelrösti mit Kräuterquark und Gurkensalat', 1.5, [FoodTag.VEGETARIAN]),
        Food('Feuriges Gemüse-Rindfleisch-Curry mit Mienudeln ', 2.3, [FoodTag.BEEF, FoodTag.GARLIC]),
        Food('Schweinesteak Förster Art mit Waldpilzsoße dazu eine Gemüsebeilage und eine Sättigungsbeilage zur Auswahl', 2.6, [FoodTag.PIG]),
        Food('5 Kartoffelrösti mit Kräuterquark und Gurkensalat', 1.5, [FoodTag.VEGETARIAN])
      ]
      )
    ];

    service._lastUpdate = DateTime(2020, 8, 24, 13, 12);
    return service;
  }

  @override
  String getName() => t.main.settings.syncItems.mensa;

  @override
  Future<void> sync() async {
    await sleep(500);
  }

  @override
  DateTime getLastUpdate() {
    return _lastUpdate;
  }

  List<Menu> getMenu() {
    return _menu;
  }
}