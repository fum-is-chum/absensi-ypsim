

class HistoryModel {
  String? tanggalAwal;
  String? tanggalAkhir;

  HistoryModel({String? tanggalAwal, String? tanggalAkhir})
      : this.tanggalAwal = tanggalAwal ?? DateTime.now().toIso8601String(),
        this.tanggalAkhir = tanggalAkhir ?? DateTime.now().toIso8601String();

  HistoryModel.fromJson(Map<String, dynamic> json) {
    tanggalAwal = json['tanggalAwal'];
    tanggalAkhir = json['tanggalAkhir'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tanggalAwal'] = this.tanggalAwal;
    data['tanggalAkhir'] = this.tanggalAkhir;
    return data;
  }
}

class HistoryBloc {
  late Map<String, dynamic> _historyModel;

  HistoryBloc() {
    _historyModel = new HistoryModel().toJson();
  }

  void setValue(String key, dynamic value) => _historyModel[key] = value;


  String getValue(String key) => _historyModel[key];
  Map<String, dynamic> getRawValue() => _historyModel;
}