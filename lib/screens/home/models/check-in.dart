import 'dart:io';
import 'package:material_kit_flutter/utils/services/shared-service.dart';

class CheckInModel {
  int? employeeId;
  String? date;
  double? latitude;
  double? longitude;
  File? photo;
  String? time;
  // lampiran

    CheckInModel({
    int? employeeId,
    String? date,
    double? latitude,
    double? longitude,
    File? photo,
    String? time
  }) :  this.employeeId = employeeId ?? 0,
        this.date = date ?? formatDateOnly(DateTime.now()),
        this.latitude = latitude ?? null,
        this.longitude = longitude ?? null,
        this.photo = photo ?? null,
        this.time = time ?? formatDateOnly(DateTime.now());

  CheckInModel.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    date = json['date'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    photo = json['photo'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employeeId'] = this.employeeId;
    data['date'] = this.date;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['photo'] = this.photo;
    data['time'] = this.time;
    return data;
  }
}
