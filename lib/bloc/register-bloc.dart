import 'dart:convert';
import 'dart:developer';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_kit_flutter/http.interceptor.dart';
import 'package:material_kit_flutter/models/register.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc {
  bool state = true;
  late BehaviorSubject<bool> _obscureText$;
  Map<String, dynamic> model = new Register().toJson();

  RegisterBloc() {
    _obscureText$ = BehaviorSubject<bool>.seeded(true);
  }

  Stream<bool> get obscureObservable {
    return _obscureText$.stream;
  }

  toggle() {
    state = !state;
    _obscureText$.sink.add(state);
  }

  Future<bool> registerUser(BuildContext context) async {
    try {
      http.Response resp = await register();
      if (resp.statusCode != 200)
        throw 'Error ${resp.statusCode}\n${jsonDecode(resp.body)['Message']}';
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "Berhasil",
              text: "Registrasi berhasil"));
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

  Future<http.Response> register() {
    const url = 'https://presensi.ypsimlibrary.com/api/register';
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
