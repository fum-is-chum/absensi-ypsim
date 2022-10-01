import 'dart:convert';

import 'package:absensi_ypsim/screens/login-register-verification/screens/login/models/login-result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crypto.dart';

class CredentialGetter {
  CredentialGetter._sharedInstance();
  static final CredentialGetter _shared = CredentialGetter._sharedInstance();
  factory CredentialGetter() => _shared;
  late SharedPreferences sharedPref;
  LoginResult? _inMemoryUserData;

  Future<void> init() async {
    sharedPref = await SharedPreferences.getInstance();
  }

  Future<String> get userAccessToken async {
    // use in memory token if available
    if (_inMemoryUserData != null && _inMemoryUserData!.AccessToken!.isNotEmpty) return _inMemoryUserData!.AccessToken!;

    // otherwise load it from local storage
    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData?.AccessToken! ?? '';
  }

  Future<LoginData> get userData async {
    if(_inMemoryUserData != null) return _inMemoryUserData!.Data!;
    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData!.Data!;
  }

  Future<int> get userId async {
    if(_inMemoryUserData != null) return _inMemoryUserData!.Data!.id!;

    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData?.Data!.id ?? 0;
  }

  Future<LoginResult?> _loadTokenFromSharedPreference() async {
    if(sharedPref.containsKey('user')) {
      LoginResult user = LoginResult.fromJson(jsonDecode(decryptAESCryptoJS(sharedPref.getString('user')!,'1!1!')));
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