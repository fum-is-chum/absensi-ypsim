import 'package:absensi_ypsim/services/shared-service.dart';

class PengajuanIzinModel {
  late int id;
  late String start_date;
  late String end_date;
  late String remark;
  dynamic file;

  // String? _filePath;

  PengajuanIzinModel({int? id, String? start_date, String? end_date, String? remark, dynamic file})
      : this.id = id ?? 0,
        this.start_date = start_date ?? formatDateOnly(DateTime.now()),
        this.end_date = end_date ?? formatDateOnly(DateTime.now()),
        this.remark = remark ?? '',
        this.file = file ?? null;

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  PengajuanIzinModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];  
    start_date = json['start_date'];
    end_date = json['end_date'];
    remark = json['remark'];
    file = json['file'];
  }
  
/*
    VSCode Regex:
    - this\.(.*),
    - data['$1'] = this.$1;
  */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['start_date'] = this.start_date;
    data['end_date'] = this.end_date;
    data['remark'] = this.remark;
    data['file'] = this.file;
    return data;
  }
}