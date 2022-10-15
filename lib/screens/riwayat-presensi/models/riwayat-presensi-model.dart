import 'package:absensi_ypsim/utils/services/shared-service.dart';

class HistoryModel {
  int id = 0;
  int employee_id = 0;
  String check_in = '';
  String check_out = '';
  String date = '';
  String status = '';
  String reason = '';
  String status_check_in = '';
  String status_check_out = '';
  String photo_check_in = '';
  String photo_check_out = '';
  String latitude_check_in = '';
  String latitude_check_out = '';
  String longitude_check_in = '';
  String longitude_check_out = '';

  HistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employee_id = json['employee_id'];
    check_in = formatDateOnly(DateTime.parse(json['check_in']));
    check_out = formatDateOnly(DateTime.parse(json['check_out']));
    date = formatDateOnly(DateTime.parse(json['date']));
    status = json['status'];
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
