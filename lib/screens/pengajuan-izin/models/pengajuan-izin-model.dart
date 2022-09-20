import 'dart:io';

import 'package:intl/intl.dart';

class PengajuanIzinModel {
  String? startDate;
  String? endDate;
  String? remark;
  File? file;

  PengajuanIzinModel({String? startDate, String? endDate, String? remark, File? file})
      : this.startDate = startDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        this.endDate = endDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
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