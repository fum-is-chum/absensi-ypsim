import 'dart:async';

import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:dio/dio.dart';
import 'package:SIMAt/utils/misc/credential-getter.dart';
import 'package:SIMAt/models/api-response.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:rxdart/rxdart.dart';

import '../models/riwayat-presensi-model.dart';

class RiwayatPresensiBloc {
  HistoryFilter _filter = HistoryFilter();
  late BehaviorSubject<bool> reloadSubject$;
  late BehaviorSubject<bool> loadingSubject$;

  RiwayatPresensiBloc() {
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
    int id = await CredentialGetter.employeeId;
    return DioClient.dio.get("/attendance/$id?start_date=${_filter.startDate}&end_date=${_filter.endDate}",
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
