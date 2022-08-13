class RequestModel {
  String? tanggalAwal;
  String? tanggalAkhir;
  String? keterangan;
  // lampiran

  RequestModel ({
    this.tanggalAwal,
    this.tanggalAkhir,
    this.keterangan
  });

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
  RequestModel _requestModel = new RequestModel();
  RequestBloc();

  // void patchValue(String key, dynamic value) {
  //   _requestModel[key] = value;
  // }
  // Future<void> submitIzin() {
    
  // }
}