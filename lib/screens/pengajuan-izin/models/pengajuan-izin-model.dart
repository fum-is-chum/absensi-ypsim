import 'dart:io';

import 'package:material_kit_flutter/services/shared-service.dart';

class PengajuanIzinModel {
  String? startDate;
  String? endDate;
  String? remark;
  File? file;

  PengajuanIzinModel({String? startDate, String? endDate, String? remark, File? file})
      : this.startDate = startDate ?? formatDateOnly(DateTime.now()),
        this.endDate = endDate ?? formatDateOnly(DateTime.now()),
        this.remark = remark ?? '',
        this.file = file ?? null;

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  PengajuanIzinModel.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
    remark = json['remark'];
    // file = json['file'];
  }

/*
    VSCode Regex:
    - this\.(.*),
    - data['$1'] = this.$1;
  */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['remark'] = this.remark;
    data['file'] = this.file;
    return data;
  }
}