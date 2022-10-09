import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:absensi_ypsim/utils/interceptors/dio-interceptor.dart';
import 'package:absensi_ypsim/screens/login-register-verification/screens/register/models/register.dart';
import 'package:absensi_ypsim/widgets/spinner.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc {
  bool state = true;
  late BehaviorSubject<bool> _obscureText$;
  late BehaviorSubject<bool> _loading$;
  Spinner sp = Spinner();
  Map<String, dynamic> model = new Register().toJson();

  RegisterBloc() {
    _obscureText$ = BehaviorSubject<bool>.seeded(true);
    _loading$ = BehaviorSubject<bool>.seeded(false);
  }

  Stream<bool> get obscureObservable {
    return _obscureText$.asBroadcastStream();
  }

  Stream<bool> get loadingObservable {
    return _loading$.asBroadcastStream();
  }

  toggleObscure() {
    state = !state;
    _obscureText$.sink.add(state);
  }

  setLoading(bool val) {
    _loading$.sink.add(val);
  }

  Future<bool> registerUser(BuildContext context) async {
    sp.show();
    try {
      await register();
      sp.hide();
      await ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "Berhasil",
              text: "Registrasi berhasil"));
      return true;
    } catch (e) {
      sp.hide();
      DioError err = e as DioError;
      String error = "";
      if(err.response != null) {
        error = "${err.message}\n${err.response != null ? err.response!.data['Message'] : err.response.toString()}";
      } else if(err.error is SocketException) {
        error = "Tidak ada koneksi";
      } else if(err.error is TimeoutException) {
        error = "${err.requestOptions.baseUrl}${err.requestOptions.path}\nRequest Timeout";
      }
      await ArtSweetAlert.show(
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

  Future<Response> register() {
    return DioClient().dio.post('/register', data: model);
  }

  void dispose() {
    _obscureText$.close();
  }
}
