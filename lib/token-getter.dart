import 'dart:convert';
import 'dart:developer';

import 'package:material_kit_flutter/models/login-result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenGetter {
  TokenGetter._sharedInstance();
  static final TokenGetter _shared = TokenGetter._sharedInstance();
  factory TokenGetter() => _shared;
  SharedPreferences? sharedPref;
  String _inMemoryToken = '';

  Future<String> get userAccessToken async {
    // use in memory token if available
    if (_inMemoryToken.isNotEmpty) return _inMemoryToken;

    // otherwise load it from local storage
    _inMemoryToken = await _loadTokenFromSharedPreference();
    return _inMemoryToken;
  }

  Future<String> _loadTokenFromSharedPreference() async {
    if(sharedPref == null) {
      sharedPref = await SharedPreferences.getInstance();
    }
    inspect(sharedPref!.getString('user'));
    if(sharedPref!.getString('user') != null) {
      LoginResult user = LoginResult.fromJson(jsonDecode(sharedPref!.getString('user')!));
      if(user.AccessToken != null) {
        return user.AccessToken!;
      }
    }
    return '';
  }

  void reset() {
    _inMemoryToken = '';
  }
}