import 'dart:convert';
import 'dart:developer';

import 'package:material_kit_flutter/models/login-result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crypto.dart';

class TokenGetter {
  TokenGetter._sharedInstance();
  static final TokenGetter _shared = TokenGetter._sharedInstance();
  factory TokenGetter() => _shared;
  SharedPreferences? sharedPref;
  LoginResult? _inMemoryUserData;

  Future<String> get userAccessToken async {
    // use in memory token if available
    if (_inMemoryUserData != null && _inMemoryUserData!.AccessToken!.isNotEmpty) return _inMemoryUserData!.AccessToken!;

    // otherwise load it from local storage
    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData?.AccessToken! ?? '';
  }

  Future<LoginResult?> _loadTokenFromSharedPreference() async {
    if(sharedPref == null) {
      sharedPref = await SharedPreferences.getInstance();
    }
    if(sharedPref!.getString('user') != null) {
      LoginResult user = LoginResult.fromJson(jsonDecode(decryptAESCryptoJS(sharedPref!.getString('user')!,'1!1!')));
      if(user.AccessToken != null) {
        return user;
      }
    }
    return null;
  }

  void reset() {
    _inMemoryUserData = null;
  }
}