import 'dart:async';
import 'dart:convert';

import 'package:SIMAt/env.dart';
import 'package:SIMAt/screens/login-register-verification/screens/login/models/login.dart';
import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:SIMAt/utils/misc/credential-getter.dart';
import 'package:SIMAt/utils/misc/crypto.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:SIMAt/widgets/spinner.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login-result.dart';

class LoginBloc {
  LoginBloc._sharedInstance();
  static final LoginBloc _shared = LoginBloc._sharedInstance();
  factory LoginBloc() => _shared;

  bool state = true;
  BehaviorSubject<bool> _obscureText$ = BehaviorSubject<bool>.seeded(true);
  Map<String, dynamic> model = new Login().toJson();
  Spinner sp = Spinner();

  Stream<bool> get counterObservable {
    return _obscureText$.stream;
  }

  toggle() {
    state = !state;
    _obscureText$.sink.add(state);
  }

  void saveCredentials(LoginResult cred) {
    SharedPreferences sharedPref = CredentialGetter.sharedPref;
    CredentialGetter.reset();
    DioClient.updateToken(cred.AccessToken);
    sharedPref.setString('user', encryptAESCryptoJS(jsonEncode(cred.toJson()),'1!1!'));
    sharedPref.setString('login', encryptAESCryptoJS(jsonEncode(model),  '&*()'));
  }

  Future<bool> loginUser({bool relogin = false}) async {
    sp.show();
    try {
      Response resp = await login(relogin: true);
      saveCredentials(LoginResult.fromJson(resp.data['Result']));
      sp.hide();
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);
      return false;
    }
  }

  Future<bool> logoutUser() async {
    try {
      sp.show();
      await logout();
      CredentialGetter.logout();
      sp.hide();
      
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);
      return false;
    }
  }

  Future<bool> relogin() async {
    try{
      // sp.show();
      // await logoutUser();
      model = await CredentialGetter.loginCredential;
      if(model['username'] == null) {
        // sp.hide();
        return false;
      }
      await loginUser(relogin: true);
      // sp.hide();
      return true;
    } catch (e) {
      // sp.hide();
      await handleError(e);
      return false;
    }
  }

  Future<Response> login({bool relogin = false}) {
    Map<String, dynamic> _model = model;
    _model['username'] = _model['username'].toString().toLowerCase();
   
    if(relogin) {
      return DioClient.reloginDio.post('/login', data: _model);
    }
    return DioClient.dio.post('/login', data: _model);
  }

  Future<Response> logout() {
    return DioClient.dio.post(
      '/logout',
      data: null,
      options: Options(
        headers: {
          'RequireToken': ''
        }
      )
    );
  }
  
  void dispose() {
    _obscureText$.close();
  }
}
