import 'dart:io';

class HistoryIzinModel {
  String? startDate;
  String? endDate;
  String? remark;
  File? file;

  HistoryIzinModel({String? startDate, String? endDate, String? remark, File? file})
      : this.startDate = startDate ?? DateTime.now().toIso8601String(),
        this.endDate = endDate ?? DateTime.now().toIso8601String(),
        this.remark = remark ?? '',
        this.file = file ?? null;

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  HistoryIzinModel.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
    remark = json['remark'];
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
    return data;
  }
}