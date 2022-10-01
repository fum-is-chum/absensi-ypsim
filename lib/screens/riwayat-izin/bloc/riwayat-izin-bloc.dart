

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:absensi_ypsim/dio-interceptor.dart';
import 'package:absensi_ypsim/misc/credential-getter.dart';
import 'package:absensi_ypsim/models/api-response.dart';
import 'package:absensi_ypsim/services/shared-service.dart';
import 'package:rxdart/rxdart.dart';

import '../models/riwayat-izin.dart';

class RiwayatIzinBloc {
  RiwayatIzinFilter _filter = RiwayatIzinFilter();
  late BehaviorSubject<bool> reloadSubject$;
  late BehaviorSubject<bool> loadingSubject$;

  RiwayatIzinBloc() {
    init();
  }

  void init() {
    reloadSubject$ = new BehaviorSubject.seeded(true);
    loadingSubject$ = new BehaviorSubject.seeded(false);
  }

  RiwayatIzinFilter get filter => _filter;
  Stream<bool> get reloadStream => reloadSubject$.asBroadcastStream();
  Stream<bool> get loadingStream => loadingSubject$.asBroadcastStream();

  triggerReload() {
    reloadSubject$.sink.add(!reloadSubject$.value);
  }

  Future<List<dynamic>> getPermission() async {
    try {
      this.loadingSubject$.sink.add(true);
      Response resp = await get();
      ApiResponse body = ApiResponse.fromJson(resp.data);
      // inspect(body.Result);
      return body.Result;
    } catch (e) {
      throw handleError(null, e);
    } finally {
      this.loadingSubject$.sink.add(false);
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
    loadingSubject$.close();
  }
}