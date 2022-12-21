import 'dart:convert';

class LoginResult {
  String? AccessToken;
  String? TokenType;
  int? IdUser;
  LoginData? Data;

  LoginResult.fromJson(Map<String, dynamic> json) {
    AccessToken = json['AccessToken'];
    TokenType = json['TokenType'];
    IdUser = json['IdUser'];
    Data = json['Data'].runtimeType == String ? LoginData.fromJson(jsonDecode(json['Data'])) : LoginData.fromJson(json['Data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AccessToken'] = this.AccessToken;
    data['TokenType'] = this.TokenType;
    data['IdUser'] = this.IdUser;
    data['Data'] = jsonEncode(this.Data);
    return data;
  }
}

class LoginData {
  int? id;
  String? jenis_pegawai;
  String? nip;
  String? nik;
  String? nama;
  String? jenis_kelamin;
  String? tempat_lahir;
  String? tanggal_lahir;
  String? alamat;
  String? email;
  String? no_hp;
  String? jabatan;
  String? agama;
  String? foto;
  String? status_pegawai;
  String? tanggal_bergabung;
  int? id_time_settings_employee;
  String? created_at;
  String? updated_at;


  LoginData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jenis_pegawai = json['jenis_pegawai'];
    nip = json['nip'];
    nik = json['nik'];
    nama = json['nama'];
    jenis_kelamin = json['jenis_kelamin'];
    tempat_lahir = json['tempat_lahir'];
    tanggal_lahir = json['tanggal_lahir'];
    alamat = json['alamat'];
    email = json['email'];
    no_hp = json['no_hp'];
    jabatan = json['jabatan'];
    agama = json['agama'];
    foto = json['foto'];
    status_pegawai = json['status_pegawai'];
    tanggal_bergabung = json['tanggal_bergabung'];
    id_time_settings_employee = json['id_time_settings_employee'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['jenis_pegawai'] = this.jenis_pegawai;
    data['this.nip'] = this.nip;
    data['nik'] = this.nik;
    data['nama'] = this.nama;
    data['jenis_kelamin'] = this.jenis_kelamin;
    data['tempat_lahir'] = this.tempat_lahir;
    data['tanggal_lahir'] = this.tanggal_lahir;
    data['alamat'] = this.alamat;
    data['email'] = this.email;
    data['no_hp'] = this.no_hp;
    data['jabatan'] = this.jabatan;
    data['agama'] = this.agama;
    data['foto'] = this.foto;
    data['status_pegawai'] = this.status_pegawai;
    data['tanggal_bergabung'] = this.tanggal_bergabung;
    data['id_time_settings_employee'] = this.id_time_settings_employee;
    data['created_at'] = this.created_at;
    data['updated_at'] = this.updated_at;
    return data;
  }
}