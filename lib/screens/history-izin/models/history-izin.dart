import 'package:material_kit_flutter/screens/history-presensi/history-presensi.dart';
import 'package:material_kit_flutter/services/shared-service.dart';

class HistoryIzinModel {
  int? id;
  int? employee_id;
  String? start_date;
  String? end_date;
  String? file;
  String? remark;
  String? status;
  String? reason; // alasan penolakan (?)
  String? created_at;
  String? updated_at;

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  HistoryIzinModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employee_id = json['employee_id'];
    start_date = formatDateOnly(DateTime.parse(json['start_date']));
    end_date = formatDateOnly(DateTime.parse(json['end_date']));
    file = json['file']; // load file from path
    remark = json['remark'];
    status = json['status'];
    reason = json['reason'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}


class HistoryIzinFilter {
  String? startDate;
  String? endDate;

  HistoryIzinFilter({String? startDate, String? endDate}) 
    : this.startDate = formatDateOnly(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7)),
      this.endDate = formatDateOnly(DateTime.now());

}