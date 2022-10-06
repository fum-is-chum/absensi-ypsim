import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:absensi_ypsim/utils/interceptors/dio-interceptor.dart';
import 'package:absensi_ypsim/models/api-response.dart';
import 'package:rxdart/rxdart.dart';

class TimeBloc {
  late BehaviorSubject<bool> reloadSubject$;
  late BehaviorSubject<String> _date;
  String count = "00:00:00";
  
  TimeBloc() {
    reloadSubject$ = new BehaviorSubject.seeded(true);
    _date = BehaviorSubject.seeded("");
  }

  Stream<bool> get reloadStream => reloadSubject$.asBroadcastStream();

  Stream<String> get dateStream$ => _date.asBroadcastStream();
  String get currentDate => _date.value;
  void updateDate(String date) {
    _date.sink.add(date);
  }

  triggerReload() {
    reloadSubject$.sink.add(!reloadSubject$.value);
  }

  Future<String> getTime(BuildContext context) async {
    try {
      Response resp = await get();
      ApiResponse body = ApiResponse.fromJson(resp.data);
      return body.Result;
    } catch (e) {
      String error = "";
      if (e is DioError) {
        if (e.response != null) {
          error = "${e.message}\n${e.response.toString()}";
        } else if (e.error is SocketException) {
          error = "Tidak ada koneksi";
        } else if (e.error is TimeoutException) {
          error =
              "${e.requestOptions.baseUrl}${e.requestOptions.path}\nRequest Timeout";
        }
      } else {
        error = e.toString();
      }
      await ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Gagal", 
            text: error
          )
      );

      return "";
    }
  }

  Future<Response> get() async {
    return DioClient().dio.get(
      "/get-time",
      options: Options(headers: {'RequireToken': ''}));
  }

  void dispose() {
    reloadSubject$.close();
    _date.close();
  }
}
