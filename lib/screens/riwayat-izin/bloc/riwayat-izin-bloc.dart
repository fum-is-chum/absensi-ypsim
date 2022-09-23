

import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_kit_flutter/dio-interceptor.dart';
import 'package:material_kit_flutter/misc/credential-getter.dart';
import 'package:material_kit_flutter/models/api-response.dart';
import 'package:rxdart/rxdart.dart';

import '../models/riwayat-izin.dart';

class RiwayatIzinBloc {
  RiwayatIzinFilter _filter = RiwayatIzinFilter();
  late BehaviorSubject<bool> reloadSubject$;

  RiwayatIzinBloc() {
    reloadSubject$ = reloadSubject$ = new BehaviorSubject.seeded(true);
  }

  RiwayatIzinFilter get filter => _filter;
  Stream<bool> get reloadStream => reloadSubject$.asBroadcastStream();

  triggerReload() {
    reloadSubject$.sink.add(!reloadSubject$.value);
  }

  Future<List<dynamic>> getPermission(BuildContext context) async {
    try {
      Response resp = await get();
      ApiResponse body = ApiResponse.fromJson(resp.data);
      // inspect(body.Result);
      return body.Result;
    } catch (e) {
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

      return [];
    }
  }

  Future<Response> get() async {
    int id = await CredentialGetter().userId;
    return DioClient().dio.get("/permission/$id?start_date=${_filter.startDate}&end_date=${_filter.endDate}",
      options:  Options(
        headers: {
          'RequireToken': ''
        }
      )
    );
  }

  void dispose() {
    reloadSubject$.close();
  }
}
