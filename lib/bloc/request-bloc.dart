class RequestModel {
  String? tanggalAwal;
  String? tanggalAkhir;
  String? keterangan;
  // lampiran

  RequestModel ({
    String? tanggalAwal,
    String? tanggalAkhir,
    String? keterangan
  }): this.tanggalAwal = tanggalAwal ?? DateTime.now().toIso8601String(),
      this.tanggalAkhir = tanggalAkhir ?? DateTime.now().toIso8601String(),
      this.keterangan = keterangan ?? '';

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  RequestModel.fromJson(Map<String, dynamic> json) {
    tanggalAwal = json['tanggalAwal'];
    tanggalAkhir = json['tanggalAkhir'];
    keterangan = json['keterangan'];
  }

  /*
    VSCode Regex:
    - this\.(.*),
    - data['$1'] = this.$1;
  */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tanggalAwal'] = this.tanggalAwal;
    data['tanggalAkhir'] = this.tanggalAkhir;
    data['keterangan'] = this.keterangan;
    return data;
  }
}

class RequestBloc {
  late Map<String, dynamic> _requestModel;

  RequestBloc() {
    _requestModel = new RequestModel().toJson();
  }

  void setValue(String key, dynamic value) => _requestModel[key] = value;

  String getValue(String key) => _requestModel[key];

  Map<String, dynamic> getRawValue() => _requestModel;
}