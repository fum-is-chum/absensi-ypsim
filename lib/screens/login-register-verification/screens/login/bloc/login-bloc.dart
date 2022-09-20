import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_kit_flutter/dio-interceptor.dart';
import 'package:material_kit_flutter/main.dart';
import 'package:material_kit_flutter/misc/credential-getter.dart';
import 'package:material_kit_flutter/misc/crypto.dart';
import 'package:material_kit_flutter/screens/Login-Register-Verification/screens/login/models/login.dart';
import 'package:material_kit_flutter/widgets/spinner.dart';
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
    inspect(cred.toJson());
    sharedPref.setString('user', encryptAESCryptoJS(jsonEncode(cred.toJson()),'1!1!'));
  }

  Future<bool> loginUser(BuildContext context) async {
    sp.show(context: context);
    try {
      Response resp = await login();
      // inspect(resp.data['Result']);
      await saveCredentials(LoginResult.fromJson(resp.data['Result']));
      sp.hide();
      return true;
    } catch (e) {
      sp.hide();
      String error = "";
      if(e is DioError) {
        if(e.response != null) {
          error = "${e.message}\n${e.response.toString()}";
        } else if(e.error is SocketException) {
          error = "Tidak ada koneksi";
        } else if(e.error is TimeoutException) {
          error = "${e.requestOptions.baseUrl}${e.requestOptions.path}\nRequest Timeout";
        }
      } else {
        error = e.toString();
      }
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Gagal",
          text: error
        )
      );
      return false;
    }
  }

  Future<bool> logoutUser(BuildContext context) async {
    try {
      sp.show(context: context);
      Response resp = await logout();
      sp.hide();
      return true;
    } catch (e) {
       sp.hide();
      String error = "";
      if(e is DioError) {
        if(e.response != null) {
          error = "${e.message}\n${e.response.toString()}";
        } else if(e.error is SocketException) {
          error = "Tidak ada koneksi";
        } else if(e.error is TimeoutException) {
          error = "${e.requestOptions.baseUrl}${e.requestOptions.path}\nRequest Timeout";
        }
      } else {
        error = e.toString();
      }
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Gagal",
            text: error
          )
        );
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
