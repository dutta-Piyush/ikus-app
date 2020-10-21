import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:ikus_app/model/mensa_info.dart';
import 'package:ikus_app/model/ovgu_account.dart';

class SettingsService {

  static final SettingsService _instance = SettingsService();
  static SettingsService get instance => _instance;
  static FlutterSecureStorage get _secureStorage => FlutterSecureStorage();

  bool _welcome;
  String _locale; // nullable
  List<int> _favorites;
  List<int> _newsChannels; // nullable
  List<int> _calendarChannels; // nullable
  List<int> _myEvents;
  Mensa _mensa;
  bool _devServer;
  OvguAccount _ovguAccount; // nullable

  /// load all settings data from local storage
  Future<void> init() async {
    Box box = _box;
    _welcome = box.get('welcome', defaultValue: true);
    _locale = box.get('locale');
    _favorites = box
        .get('favorite_feature_list', defaultValue: [])
        ?.cast<int>();
    _newsChannels = box
        .get('news_channels')
        ?.cast<int>();
    _calendarChannels = box
        .get('calendar_channels')
        ?.cast<int>();
    _myEvents = box
        .get('my_events', defaultValue: [])
        .cast<int>();
    _mensa = (box.get('mensa') as String)?.toMensa() ?? Mensa.UNI_CAMPUS_DOWN;
    _devServer = box.get('dev_server', defaultValue: false);

    // secure storage
    final storage = _secureStorage;
    String ovguName = await storage.read(key: 'ovgu_name');
    String ovguPassword = await storage.read(key: 'ovgu_password');
    _ovguAccount = ovguName != null && ovguPassword != null ? OvguAccount(name: ovguName, password: ovguPassword) : null;
  }

  Box get _box  => Hive.box('settings');

  void setWelcome(bool welcome) {
    _box.put('welcome', welcome);
    _welcome = welcome;
  }

  bool getWelcome() {
    return _welcome;
  }

  void setLocale(String locale) {
    _box.put('locale', locale);
    _locale = locale;
  }

  String getLocale() {
    return _locale;
  }

  void setFavorites(List<int> favorites) {
    _box.put('favorite_feature_list', favorites);
    _favorites = favorites;
  }

  List<int> getFavorites() {
    return _favorites;
  }

  void setNewsChannels(List<int> channels) {
    _box.put('news_channels', channels);
    _newsChannels = channels;
  }

  List<int> getNewsChannels() {
    return _newsChannels;
  }

  void setCalendarChannels(List<int> channels) {
    _box.put('calendar_channels', channels);
    _calendarChannels = channels;
  }

  List<int> getCalendarChannels() {
    return _calendarChannels;
  }

  void setMyEvents(List<int> events) {
    _box.put('my_events', events);
    _myEvents = events;
  }

  List<int> getMyEvents() {
    return _myEvents;
  }

  void setMensa(Mensa mensa) {
    _box.put('mensa', describeEnum(mensa));
    _mensa = mensa;
  }

  Mensa getMensa() {
    return _mensa;
  }

  void setDevServer(bool dev) {
    _box.put('dev_server', dev);
    _devServer = dev;
  }

  bool getDevServer() {
    return _devServer;
  }

  Future<void> setOvguAccount({@required String name, @required String password}) async {
    final storage = _secureStorage;
    await storage.write(key: 'ovgu_name', value: name);
    await storage.write(key: 'ovgu_password', value: password);
    _ovguAccount = OvguAccount(name: name, password: password);
  }

  Future<void> deleteOvguAccount() async {
    final storage = _secureStorage;
    await storage.delete(key: 'ovgu_name');
    await storage.delete(key: 'ovgu_password');
    _ovguAccount = null;
  }

  bool hasOvguAccount() {
    return _ovguAccount != null;
  }

  OvguAccount getOvguAccount() {
    return _ovguAccount;
  }

  /// reinitialize with default values
  /// keeps dev server attribute alive
  Future<void> clear() async {
    bool devServer = _devServer;
    await _box.clear();
    await _secureStorage.deleteAll();
    await init();
    setDevServer(devServer);
  }
}