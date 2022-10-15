import 'dart:async';

import 'package:absensi_ypsim/utils/interceptors/dio-interceptor.dart';
import 'package:dio/dio.dart';
import 'package:absensi_ypsim/utils/misc/credential-getter.dart';
import 'package:absensi_ypsim/models/api-response.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:rxdart/rxdart.dart';

import '../models/riwayat-presensi-model.dart';

class HistoryBloc {
  HistoryFilter _filter = HistoryFilter();
  late BehaviorSubject<bool> reloadSubject$;
  late BehaviorSubject<bool> loadingSubject$;

  HistoryBloc() {
    init();
  }

  void init() {
    reloadSubject$ = new BehaviorSubject.seeded(true);
    loadingSubject$ = new BehaviorSubject.seeded(false);
  }

  HistoryFilter get filter => _filter;
  Stream<bool> get reloadStream => reloadSubject$.asBroadcastStream();
  Stream<bool> get loadingStream => loadingSubject$.asBroadcastStream();

  triggerReload() {
    reloadSubject$.sink.add(!reloadSubject$.value);
  }

  Future<List<dynamic>> getAttendances() async {
    try {
      this.loadingSubject$.sink.add(true);
      Response resp = await get();
      ApiResponse body = ApiResponse.fromJson(resp.data);
      
      return body.Result;
    } catch (e) {
      throw await handleError(e);
    } finally {
      this.loadingSubject$.sink.add(false);
    }
  }

  Future<Response> get() async {
    int id = await CredentialGetter().userId;
    return DioClient().dio.get("/attendance/$id?start_date=${_filter.startDate}&end_date=${_filter.endDate}",
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
