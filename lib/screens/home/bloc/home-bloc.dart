import 'package:SIMAt/models/api-response.dart';
import 'package:SIMAt/screens/home/models/check-in.dart';
import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:SIMAt/utils/misc/credential-getter.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:SIMAt/widgets/spinner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  Spinner sp = Spinner();
  late BehaviorSubject<Map<String, dynamic>> _attendanceStatus;
  late BehaviorSubject<bool> _reloadAttendanceStatus;

  HomeBloc._();
  static final _instance = HomeBloc._();
  factory HomeBloc() {
    return _instance; // singleton service
  }

  void init() {
    _attendanceStatus = BehaviorSubject.seeded({});
    _reloadAttendanceStatus = BehaviorSubject.seeded(false);
  }

  void dispose() {
    _attendanceStatus.close();
    _reloadAttendanceStatus.close();
  }

  Stream<bool> get reloadAttendance$ =>
      _reloadAttendanceStatus.asBroadcastStream();
  void triggerReload() {
    _reloadAttendanceStatus.sink.add(!_reloadAttendanceStatus.value);
  }

  Stream<Map<String, dynamic>> get attendanceStatus$ =>
      _attendanceStatus.asBroadcastStream();

  Map<String, dynamic> get attendanceStatus => _attendanceStatus.value;

  Future<bool> getAttendanceStatus({required String date}) async {
    sp.show();
    try {
      Map<String, dynamic> data =
          ApiResponse.fromJson((await _getAttendanceStatus(date: date)).data!)
              .Result;
      // khusus endpoint getAttendanceStatus, pastikan time_settings != null
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
    required dynamic photo,
  }) async {
    sp.show();
    try {
      Response response =
          await _checkIn(pos: pos, dateTime: dateTime, photo: photo);
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
    required dynamic photo,
  }) async {
    sp.show();
    try {
      Response response =
          await _checkOut(pos: pos, dateTime: dateTime, photo: photo);
      sp.hide();
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);
      return false;
    }
  }

  Future<Response> _checkIn(
      {required Position pos,
      required String dateTime,
      required dynamic photo}) async {
    CheckInOutModel checkInModel = CheckInOutModel();
    checkInModel.employee_id = await CredentialGetter.employeeId;
    checkInModel.latitude = pos.latitude;
    checkInModel.longitude = pos.longitude;
    checkInModel.date = dateTime.substring(0, 10);
    checkInModel.time = dateTime.substring(11, 19);
    FormData formData;

    formData = FormData.fromMap({
      ...checkInModel.toJson(),
      'photo': MultipartFile.fromBytes(photo.readAsBytesSync(),
          filename: basename(photo.path)),
    });

    // return DioClient.plainDio.post('/attendance/checkIn', data: formData);
    return DioClient.plainDio.post('/attendance/checkIn',
        data: formData, options: Options(headers: {'RequireToken': ''}));
  }

  Future<Response> _checkOut(
      {required Position pos,
      required String dateTime,
      required dynamic photo}) async {
    CheckInOutModel checkOutModel = CheckInOutModel();
    checkOutModel.employee_id = await CredentialGetter.employeeId;
    checkOutModel.latitude = pos.latitude;
    checkOutModel.longitude = pos.longitude;
    checkOutModel.date = dateTime.substring(0, 10);
    checkOutModel.time = dateTime.substring(11, 19);
    FormData formData;

    formData = FormData.fromMap({
      ...checkOutModel.toJson(),
      'photo': MultipartFile.fromBytes(photo.readAsBytesSync(),
          filename: basename(photo.path)),
    });
    return DioClient.plainDio.post('/attendance/checkOut',
        data: formData, options: Options(headers: {'RequireToken': ''}));
  }

  Future<Response> _getAttendanceStatus({required String date}) async {
    Map<String, dynamic> data = {};
    data['employee_id'] = await CredentialGetter.employeeId;
    data['date'] = date;

    return DioClient.dio.post('/attendance/status',
        data: data, options: Options(headers: {'RequireToken': ''}));
  }
}
