class HomeModel {
  String? checkInImg;
  String? checkInTime;
  String? checkOutImg;
  String? checkOutTime;

  HomeModel ({
    this.checkInImg,
    this.checkInTime,
    this.checkOutImg,
    this.checkOutTime
  });

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  HomeModel.fromJson(Map<String, dynamic> json) {
    checkInImg = json['checkInImg'] ?? '';
    checkInTime = json['checkInTime'] ?? '';
    checkOutImg = json['checkOutImg'] ?? '';
    checkOutTime = json['checkOutTime'] ?? '';
  }

  /*
    VSCode Regex:
    - this\.(.*),
    - data['$1'] = this.$1;
  */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checkInImg'] = this.checkInImg;
    data['checkInTime'] = this.checkInTime;
    data['checkOutImg'] = this.checkOutImg;
    data['checkOutTime'] = this.checkOutTime;
    return data;
  }
}

class HomeBloc {
  HomeBloc._();
  static final _instance = HomeBloc._();
  HomeModel status = new HomeModel.fromJson({});
  factory HomeBloc() {
    return _instance; // singleton
  }

  /// false -> untuk checkin, true -> untuk checkout, nilai berubah sesuai dengan response API
  bool statusAbsensi() { 
    if(status.checkInTime == '' && status.checkInImg == '') {
      return false;
    }
    return status.checkOutTime == '' && status.checkOutImg == '';
  }
}