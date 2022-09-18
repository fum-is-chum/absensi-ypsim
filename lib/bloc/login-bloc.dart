import 'package:rxdart/rxdart.dart';

import 'dart:convert';
import 'dart:developer';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_kit_flutter/http.interceptor.dart';
import 'package:material_kit_flutter/models/login.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  bool state = true;
  late BehaviorSubject<bool> _obscureText$;
  Map<String, dynamic> model = new Login().toJson();

  LoginBloc() {
    _obscureText$ = BehaviorSubject<bool>.seeded(true);
  }

  Stream<bool> get counterObservable {
    return _obscureText$.stream;
  }

  toggle() {
    state = !state;
    _obscureText$.sink.add(state);
  }

  Future<bool> loginUser(BuildContext context) async {
    try {
      http.Response resp = await login();
      if (resp.statusCode == 401) {
        Navigator.pushNamed(context, '/verification');
        return false;
      } else if (resp.statusCode != 200)
        throw 'Error ${resp.statusCode}\n${jsonDecode(resp.body)['Message']}';
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "Berhasil",
              text: "Login berhasil"));
      return true;
    } catch (e) {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Gagal",
              text: e.toString()));
      return false;
    }
  }

  Future<http.Response> login() {
    const url = 'https://presensi.ypsimlibrary.com/api/login';
    return AuthenticatedHttpClient().post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(model));
  }

  void dispose() {
    _obscureText$.close();
  }
}
