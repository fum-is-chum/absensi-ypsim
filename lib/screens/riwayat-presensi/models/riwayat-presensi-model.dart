import 'package:absensi_ypsim/utils/services/shared-service.dart';

class RiwayatPresensiModel {
  int id = 0;
  int employee_id = 0;
  late String check_in;
  late String check_out;
  String date = '';
  late String status;
  String? reason;
  int status_check_in = 0;
  int status_check_out = 0;
  String? photo_check_in;
  String? photo_check_out;
  double? latitude_check_in;
  double? latitude_check_out;
  double? longitude_check_in;
  double? longitude_check_out;

  RiwayatPresensiModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employee_id = json['employee_id'];
    check_in = json['check_in'] ?? "00:00:00";
    check_out = json['check_out'] ?? "00:00:00";
    date = formatDateOnly(DateTime.parse(json['date']));
    status = json['status'] ?? "Absen";
    reason = json['reason'];
    status_check_in = json['status_check_in'];
    status_check_out = json['status_check_out'];
    photo_check_in = json['photo_check_in'];
    photo_check_out = json['photo_check_out'];
    latitude_check_in = json['latitude_check_in'];
    latitude_check_out = json['latitude_check_out'];
    longitude_check_in = json['longitude_check_in'];
    longitude_check_out = json['longitude_check_out'];
  }
}

class HistoryFilter {
  String? startDate;
  String? endDate;

  HistoryFilter({String? startDate, String? endDate})
      : this.startDate = formatDateOnly(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7)),
        this.endDate = formatDateOnly(DateTime.now());
}
