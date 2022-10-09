import 'dart:async';
import 'dart:convert';

import 'package:absensi_ypsim/screens/login-register-verification/screens/login/models/login.dart';
import 'package:absensi_ypsim/utils/interceptors/dio-interceptor.dart';
import 'package:absensi_ypsim/utils/misc/credential-getter.dart';
import 'package:absensi_ypsim/utils/misc/crypto.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:absensi_ypsim/widgets/spinner.dart';
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

  Future<void> saveCredentials(LoginResult cred) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('user', encryptAESCryptoJS(jsonEncode(cred.toJson()),'1!1!'));
    sharedPref.setString('login', encryptAESCryptoJS(jsonEncode(model),  '&*()'));
  }

  Future<bool> loginUser() async {
    sp.show();
    try {
      Response resp = await login();
      // inspect(resp.data['Result']);
      await saveCredentials(LoginResult.fromJson(resp.data['Result']));
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
      sp.show();
      model = await CredentialGetter().loginCredential;
      if(model['username'] == null) {
        sp.hide();
        return false;
      }
      await login();
      sp.hide();
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);
      return false;
    }
  }

  Future<Response> login() {
    return DioClient().dio.post('/login', data: model);
  }

  Future<Response> logout() {
    return DioClient().dio.post(
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
