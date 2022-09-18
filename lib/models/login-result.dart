class LoginResult {
  String? AccessToken;
  String? TokenType;
  // lampiran

  LoginResult({String? AccessToken, String? TokenType})
      : this.AccessToken = AccessToken ?? '',
        this.TokenType = TokenType ?? '';

  /*
    VSCode Regex:
    - this\.(.*),
    - $1 = json['$1'];
  */
  LoginResult.fromJson(Map<String, dynamic> json) {
    AccessToken = json['AccessToken'];
    TokenType = json['TokenType'];
  }

  /*
    VSCode Regex:
    - this\.(.*),
    - data['$1'] = this.$1;
  */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AccessToken'] = this.AccessToken;
    data['TokenType'] = this.TokenType;
    return data;
  }
}
