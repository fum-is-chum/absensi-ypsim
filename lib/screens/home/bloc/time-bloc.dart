import 'dart:async';

import 'package:SIMAt/models/api-response.dart';
import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class TimeBloc {
  late BehaviorSubject<bool> reloadSubject$;
  late BehaviorSubject<String> _date;
  BehaviorSubject<String> _count = BehaviorSubject.seeded("00:00:00");
  
  TimeBloc._();
  static final _instance = TimeBloc._();
  factory TimeBloc() {
    return _instance; // singleton service
  }

  void init() {
    reloadSubject$ = new BehaviorSubject.seeded(true);
    _date = BehaviorSubject.seeded(formatDateOnly(DateTime.now()));
  }
  
  Stream<bool> get reloadStream => reloadSubject$.asBroadcastStream();
  Stream<String> get dateStream$ => _date.asBroadcastStream();
  Stream<String> get count$ => _count.asBroadcastStream();
  
  String get currentTime => _count.value;
  
  void updateCount(String val) {
    _count.sink.add(val);
  }
  
  String get currentDate => _date.value;
  void updateDate(String date) {
    if(!_date.isClosed) _date.sink.add(date);
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
      handleError(e);
      return "";
    }
  }

  Future<Response> get() async {
    return DioClient.dio.get(
      "/get-time",
      options: Options(headers: {'RequireToken': ''}));
  }

  void dispose() {
    reloadSubject$.close();
    _date.close();
  }
}
