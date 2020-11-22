import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ikus_app/constants.dart';
import 'package:ikus_app/init.dart';
import 'package:ikus_app/model/api_data.dart';
import 'package:ikus_app/service/app_config_service.dart';
import 'package:ikus_app/service/jwt_service.dart';
import 'package:ikus_app/service/persistent_service.dart';
import 'package:ikus_app/service/settings_service.dart';
import 'package:intl/intl.dart';

/// manages data from the server
/// e.g. raw json, pdfs, images
class ApiService {

  static String get URL => SettingsService.instance.getDevServer() ? Constants.apiUrlDebug : Constants.apiUrlLive;
  static final DateTime FALLBACK_TIME = DateTime(2020, 8, 1);
  static final DateFormat _lastModifiedFormatter = DateFormat("E, dd MMM yyyy HH:mm:ss 'GMT'", 'en');

  static String getFileUrl(String fileName) {
    return '$URL/file/$fileName';
  }

  static Future<ApiData<String>> getCacheOrFetchString({String route, String locale, bool useCacheOnly, fallback}) async {

    Response response;
    if ((!Init.postInitFinished || AppConfigService.instance.isCompatibleWithApi() != false) && !useCacheOnly) {
      try {
        response = await get('$URL/$route?locale=${locale.toUpperCase()}');
        print('[${response.statusCode}] $route');
      } catch (_) {
        print('failed to fetch $route');
      }
    }

    final String key = 'api_json/$route';
    if (response != null && response.statusCode == 200) {
      ApiData<String> newData = ApiData(data: response.body, timestamp: DateTime.now());
      PersistentService.instance.setApiJson(key, newData);
      return newData;
    } else {
      return PersistentService.instance.getApiJson(key) ?? ApiData(data: jsonEncode(fallback), timestamp: FALLBACK_TIME);
    }
  }

  static Future<ApiData<Uint8List>> getCacheOrFetchBinary({String route, bool useCacheOnly, fallback}) async {
    Response response;
    final String key = 'api_binary/$route';

    if ((!Init.postInitFinished || AppConfigService.instance.isCompatibleWithApi() != false) && !useCacheOnly) {
      try {
        DateTime timestamp = PersistentService.instance.getApiTimestamp(key) ?? FALLBACK_TIME;
        response = await get('$URL/file/$route', headers: {
          'If-Modified-Since': _lastModifiedFormatter.format(timestamp.toUtc())
        });
        print('[${response.statusCode}] $route');
      } catch (_) {
        print('failed to fetch $route');
      }
    }

    if (response != null && response.statusCode == 200) {
      ApiData<Uint8List> newData = ApiData(data: response.bodyBytes, timestamp: DateTime.now());
      PersistentService.instance.setApiBinary(key, newData);
      return newData;
    } else {
      return PersistentService.instance.getApiBinary(key) ?? ApiData(data: fallback, timestamp: FALLBACK_TIME);
    }
  }

  static Future<void> appStart(BuildContext context) async {
    TargetPlatform platform = Theme.of(context).platform;
    String deviceId = PersistentService.instance.getDeviceId();

    Map<String, dynamic> body = {
      'token': JwtService.generateToken(),
      'deviceId': deviceId,
      'platform': platform == TargetPlatform.iOS ? 'IOS' : 'ANDROID',
    };

    await post(
      '$URL/start',
      headers: {'content-type': 'application/json'},
      body: json.encode(body)
    );
  }
}