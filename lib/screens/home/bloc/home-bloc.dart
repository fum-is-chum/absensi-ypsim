import 'dart:io';

import 'package:absensi_ypsim/models/api-response.dart';
import 'package:absensi_ypsim/screens/home/models/check-in.dart';
import 'package:absensi_ypsim/utils/interceptors/dio-interceptor.dart';
import 'package:absensi_ypsim/utils/misc/credential-getter.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:absensi_ypsim/widgets/spinner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  Spinner sp = Spinner();
  late BehaviorSubject<Map<String, dynamic>> _attendanceStatus;
  late BehaviorSubject<void> _reloadAttendanceStatus;

  HomeBloc._();
  static final _instance = HomeBloc._();
  factory HomeBloc() {
    return _instance; // singleton service
  }

  void init() {
    _attendanceStatus = BehaviorSubject.seeded({});
    _reloadAttendanceStatus = BehaviorSubject.seeded(null);
  }

  void dispose() {
    _attendanceStatus.close();
    _reloadAttendanceStatus.close();
  }

  Stream<void> get reloadAttendance$ => _reloadAttendanceStatus.asBroadcastStream();
  void triggerReload() {
    _reloadAttendanceStatus.sink.add(null);
  }

  Stream<Map<String, dynamic>> get attendanceStatus$ => _attendanceStatus.asBroadcastStream();

  Map<String, dynamic> get attendanceStatus => _attendanceStatus.value;

  Future<bool> getAttendanceStatus({
    required String date
  }) async {
    sp.show();
    try {
      Map<String, dynamic> data = ApiResponse.fromJson((await _getAttendanceStatus(date: date)).data!).Result;
      // inspect(data);
      this._attendanceStatus.sink.add(data);
      sp.hide();
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);
      return false;
    }
  }

  Future<bool> checkIn({
    required BuildContext context,
    required Position pos,
    required String dateTime,
    required File photo,
  }) async {
    sp.show();
    try {
      Response response = await _checkIn(pos: pos, dateTime: dateTime, photo: photo);
      sp.hide();
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);
      return false;
    }
   }

   Future<bool> checkOut({
    required BuildContext context,
    required Position pos,
    required String dateTime,
    required File photo,
  }) async {
    sp.show();
    try {
      Response response = await _checkOut(pos: pos, dateTime: dateTime, photo: photo);
      sp.hide();
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);;
      return false;
    }
   }

  Future<Response> _checkIn({
    required Position pos,
    required String dateTime,
    required File photo
  }) async {
    CheckInOutModel checkInModel = CheckInOutModel();
    checkInModel.employee_id = await CredentialGetter().userId;
    checkInModel.latitude = pos.latitude;
    checkInModel.longitude = pos.longitude;
    checkInModel.date = dateTime.substring(0, 10);
    checkInModel.time = dateTime.substring(11, 19);
    
    var formData = FormData.fromMap({
      ...checkInModel.toJson(),
      'photo': MultipartFile.fromBytes(
                photo.readAsBytesSync(),
                filename: basename(photo.path)
      ),
    });

    return DioClient().dioWithResponseType(ResponseType.plain).post(
      '/attendance/checkIn',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip, deflat, br',
          'RequireToken': ''
        }
      )
    );
  }

  Future<Response> _checkOut({
    required Position pos,
    required String dateTime,
    required File photo
  }) async {
    CheckInOutModel checkOutModel = CheckInOutModel();
    checkOutModel.employee_id = await CredentialGetter().userId;
    checkOutModel.latitude = pos.latitude;
    checkOutModel.longitude = pos.longitude;
    checkOutModel.date = dateTime.substring(0, 10);
    checkOutModel.time = dateTime.substring(11, 19);
    
    var formData = FormData.fromMap({
      ...checkOutModel.toJson(),
      'photo': MultipartFile.fromBytes(
                photo.readAsBytesSync(),
                filename: basename(photo.path)
      ),
    });

    return DioClient().dioWithResponseType(ResponseType.plain).post(
      '/attendance/checkOut',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip, deflat, br',
          'RequireToken': ''
        }
      )
    );
  }

  Future<Response> _getAttendanceStatus({
    required String date
  }) async {
    Map<String, dynamic> data = {};
    data['employee_id'] = await CredentialGetter().userId;
    data['date'] = date;

    return DioClient().dio.post(
      '/attendance/status',
      data: data,
      options: Options(
        headers: {
          'RequireToken': ''
        }
      )
    );
  }
}