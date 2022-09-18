class Login {
  String? username;
  String? password;
  // lampiran

  Login({String? username, String? password})
      : this.username = username ?? '',
        this.password = password ?? '';

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  Login.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
  }

  /*
    VSCode Regex:
    - this\.(.*),
    - data['$1'] = this.$1;
  */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['password'] = this.password;
    return data;
  }
}
