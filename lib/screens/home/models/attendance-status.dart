import 'package:absensi_ypsim/utils/services/shared-service.dart';

class AttendanceStatus {
  int? employee_id;
  String? date;
  int? check_in;
  int? check_out;
  String? status;
  String? photo_check_in;
  String? photo_check_out;

  AttendanceStatus({
    int? employee_id,
    String? date,
    int? check_in,
    int? check_out,
    String? status,
    String? photo_check_in,
    String? photo_check_out
  }) :  this.employee_id = employee_id ?? 0,
        this.date = date ?? formatDateOnly(DateTime.now()),
        this.check_in = check_in ?? null,
        this.check_out = check_out ?? null,
        this.status = status ?? null,
        this.photo_check_in = photo_check_in ?? null,
        this.photo_check_out = photo_check_out ?? null;

  AttendanceStatus.fromJson(Map<String, dynamic> json) {
    employee_id = json['employee_id'];
    date = json['date'];
    check_in = json['check_in'];
    check_out = json['check_out'];
    photo_check_in = json['photo_check_in'];
    photo_check_out = json['photo_check_out'];
  }

  
}