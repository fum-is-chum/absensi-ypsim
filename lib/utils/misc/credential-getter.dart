import 'dart:convert';

import 'package:SIMAt/screens/login-register-verification/screens/login/models/login-result.dart';
import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crypto.dart';

class CredentialGetter {
  CredentialGetter._sharedInstance();
  static final CredentialGetter _shared = CredentialGetter._sharedInstance();
  factory CredentialGetter() => _shared;
  static SharedPreferences? _sharedPref;

  static LoginResult? _inMemoryUserData;
  static int? _userId;
  static Map<String, dynamic> _loginCredential = {};

  static Future<void> init() async {
    if (_sharedPref == null) {
      _sharedPref = await SharedPreferences.getInstance();
      _inMemoryUserData = await _loadTokenFromSharedPreference();

    }
  }

  static get sharedPref => _sharedPref;

  static Future<String> get userAccessToken async {
    // use in memory token if available
    if (_inMemoryUserData != null && _inMemoryUserData!.AccessToken!.isNotEmpty) return _inMemoryUserData!.AccessToken!;

    // otherwise load it from local storage
    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData?.AccessToken! ?? '';
  }

  static Future<LoginData> get userData async {
    if(_inMemoryUserData != null) return _inMemoryUserData!.Data!;
    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData!.Data!;
  }

  static Future<Map<String, dynamic>> get loginCredential async {
    if(_loginCredential['username'] != null) return _loginCredential;
    _loginCredential = await _loadLoginCredential();
    return _loginCredential;
  }

  static Future<bool> updatePassword(String newPassword) async {
    try {
      if(_sharedPref == null) await init();
      Map<String, dynamic> newCredential = await CredentialGetter.loginCredential;
      newCredential['password'] = newPassword;
      sharedPref.setString('login', encryptAESCryptoJS(jsonEncode(newCredential),  '&*()'));
      return true;
    } catch (e) {
      throw(e);
    }
  }

  static Future<int> get employeeId async {
    if(_inMemoryUserData != null) return _inMemoryUserData!.Data!.id!;

    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData?.Data!.id ?? 0;
  }

  static Future<int> get userId async {
    if(_inMemoryUserData != null) return _inMemoryUserData!.IdUser!;

    _inMemoryUserData = await _loadTokenFromSharedPreference();
    return _inMemoryUserData?.IdUser ?? -1;
  }

  static Future<LoginResult?> _loadTokenFromSharedPreference() async {
    if(_sharedPref == null) {
      await init();
    }
    if(_sharedPref!.containsKey('user')) {
      LoginResult user = LoginResult.fromJson(jsonDecode(decryptAESCryptoJS(_sharedPref!.getString('user')!,'1!1!')));
      if(user.AccessToken != null) {
        DioClient.updateToken(user.AccessToken);
        return user;
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>> _loadLoginCredential() async {
    if(_sharedPref == null) {
      await init();
    }
    if(_sharedPref!.containsKey('login')) {
      return jsonDecode(decryptAESCryptoJS(_sharedPref!.getString('login')!, '&*()'));
    }
    return {};
  }

  static void reset() {
    _inMemoryUserData = null;
    _loginCredential = {};
  }

  static void logout() {
    if(_sharedPref == null) {
      init().then((value) {
        if(_sharedPref!.containsKey('user')) _sharedPref!.remove('user');
        if(_sharedPref!.containsKey('login')) _sharedPref!.remove('login');
      });
    } else {
      if(_sharedPref!.containsKey('user')) _sharedPref!.remove('user');
      if(_sharedPref!.containsKey('login')) _sharedPref!.remove('login');
    }
  }
}