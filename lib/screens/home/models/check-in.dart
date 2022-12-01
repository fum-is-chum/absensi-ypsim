import 'dart:io';
import 'package:SIMAt/utils/services/shared-service.dart';

class CheckInOutModel {
  int? employee_id;
  String? date;
  double? latitude;
  double? longitude;
  File? photo;
  String? time;
  // lampiran

  CheckInOutModel({
    int? employee_id,
    String? date,
    double? latitude,
    double? longitude,
    File? photo,
    String? time
  }) :  this.employee_id = employee_id ?? 0,
        this.date = date ?? formatDateOnly(DateTime.now()),
        this.latitude = latitude ?? null,
        this.longitude = longitude ?? null,
        this.photo = photo ?? null,
        this.time = time ?? formatDateOnly(DateTime.now());

  CheckInOutModel.fromJson(Map<String, dynamic> json) {
    employee_id = json['employee_id'];
    date = json['date'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    photo = json['photo'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employee_id'] = this.employee_id;
    data['date'] = this.date;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['photo'] = this.photo;
    data['time'] = this.time;
    return data;
  }
}
