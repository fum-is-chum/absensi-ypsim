class HistoryIzinModel {
  String? tanggalAwal;
  String? tanggalAkhir;

  HistoryIzinModel({String? tanggalAwal, String? tanggalAkhir})
      : this.tanggalAwal = tanggalAwal ?? DateTime.now().toIso8601String(),
        this.tanggalAkhir = tanggalAkhir ?? DateTime.now().toIso8601String();

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  HistoryIzinModel.fromJson(Map<String, dynamic> json) {
    tanggalAwal = json['tanggalAwal'];
    tanggalAkhir = json['tanggalAkhir'];
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
    return data;
  }
}

class HistoryIzinBloc {
  late Map<String, dynamic> _historyIzinModel;

  HistoryIzinBloc() {
    _historyIzinModel = new HistoryIzinModel().toJson();
  }

  void setValue(String key, dynamic value) => _historyIzinModel[key] = value;

  String getValue(String key) => _historyIzinModel[key];

  Map<String, dynamic> getRawValue() => _historyIzinModel;
}
