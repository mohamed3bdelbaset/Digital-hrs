import 'dart:convert';
import 'dart:io';

import 'package:cnattendance/data/source/datastore/preferences.dart';
import 'package:cnattendance/data/source/network/model/login/Loginresponse.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cnattendance/utils/deviceuuid.dart';
import 'package:cnattendance/utils/constant.dart';

class Auth with ChangeNotifier {
  String appUrl = "";
  Preferences preferences = Preferences();

  Future<void> saveAppUrl(String value) async {
    try {
      String decoded = utf8.decode(base64.decode(value));

      if (!decoded.startsWith("http://") && !decoded.startsWith("https://")) {
        showSnackbar("Invalid QR Code");
        return;
      }

      await preferences.saveAppUrl(decoded);

      appUrl = decoded;
      notifyListeners();
    } catch (e) {
      showSnackbar("Invalid QR Code, Try again");
    }
  }

// يرجع المستخدم لشاشة Scan QR
  Future<void> resetAppUrl() async {
    await preferences.saveAppUrl("");

    appUrl = "";
    notifyListeners();
  }

// تخطي QR واستخدام الرابط الافتراضي
  Future<void> skipAppUrl() async {
    await preferences.saveAppUrl(Constant.appUrl);

    appUrl = Constant.appUrl;
    notifyListeners();
  }

  Future<void> getAppUrl() async {
    appUrl = await preferences.getAppUrl();
    notifyListeners();
  }

  Future<Loginresponse> login(String username, String password) async {
    var uri = Uri.parse(await preferences.getAppUrl() + Constant.LOGIN_URL);
    print(uri);

    Map<String, String> headers = {"Accept": "application/json; charset=UTF-8"};

    try {
      var fcm = await FirebaseMessaging.instance.getToken();
      print(fcm);
      final response = await http.post(uri, headers: headers, body: {
        'username': username,
        'password': password,
        'fcm_token': fcm,
        'device_type': Platform.isIOS ? 'ios' : 'android',
        'uuid': await DeviceUUid().getUniqueDeviceId(),
      });

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(response.statusCode.toString());
        print(responseData.toString());

        Preferences preferences = Preferences();
        final responseJson = Loginresponse.fromJson(responseData);
        await preferences.saveUser(responseJson.data);

        return responseJson;
      } else {
        var errorMessage = responseData['message'];
        throw errorMessage;
      }
    } catch (error) {
      throw error;
    }
  }
}
