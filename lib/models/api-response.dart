class ApiResponse {
  int? StatusCode;
  String? Message;
  dynamic Result;
  // lampiran

    ApiResponse({
    int? StatusCode,
    String? Message,
    dynamic Result
  }) :  this.StatusCode = StatusCode ?? 0,
        this.Message = Message ?? '',
        this.Result = Result ?? {};


  ApiResponse.fromJson(Map<String, dynamic> json) {
    StatusCode = json['StatusCode'];
    Message = json['Message'];
    Result = json['Result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StatusCode'] = this.StatusCode;
    data['Message'] = this.Message;
    data['Result'] = this.Result;
    return data;
  }
}
