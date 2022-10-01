class Register {
  String? nik;
  String? username;
  String? password;
  // lampiran

  Register({String? nik, String? username, String? password})
      : this.nik = nik ?? '',
        this.username = username ?? '',
        this.password = password ?? '';

  Register.fromJson(Map<String, dynamic> json) {
    nik = json['nik'];
    username = json['username'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nik'] = this.nik;
    data['username'] = this.username;
    data['password'] = this.password;
    return data;
  }
}
