import 'package:absensi_ypsim/services/shared-service.dart';

class RiwayatIzinModel {
  int id = 0;
  int employee_id = 0;
  String start_date = '';
  String end_date = '';
  String? file;
  String remark = '';
  String status = 'Pending';
  String? reason; // alasan penolakan (?)
  String created_at = '';
  String updated_at = '';

  RiwayatIzinModel.fromJson(Map<String, dynamic> json) {
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


class RiwayatIzinFilter {
  String? startDate;
  String? endDate;

  RiwayatIzinFilter({String? startDate, String? endDate}) 
    : this.startDate = formatDateOnly(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7)),
      this.endDate = formatDateOnly(DateTime.now());

}