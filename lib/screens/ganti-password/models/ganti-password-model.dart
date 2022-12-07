class GantiPasswordModel {
  late int id;
  late String password_lama;
  late String password_baru;
  late String konfirmasi_password_baru;

  GantiPasswordModel({int? id, String? password_lama, String? password_baru, String? konfirmasi_password_baru})
      : this.id = id ?? 0,
        this.password_lama = password_lama ?? '',
        this.password_baru = password_baru ?? '',
        this.konfirmasi_password_baru = konfirmasi_password_baru ?? '';

  GantiPasswordModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];  
    password_lama = json['password_lama'];
    password_baru = json['password_baru'];
    konfirmasi_password_baru = json['konfirmasi_password_baru'];
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['password_lama'] = this.password_lama;
    data['password_baru'] = this.password_baru;
    data['konfirmasi_password_baru'] = this.konfirmasi_password_baru;
    return data;
  }
}