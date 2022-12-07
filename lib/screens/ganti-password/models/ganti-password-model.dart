class GantiPasswordModel {
  late int id;
  late String oldPassword;
  late String newPassword;
  late String confirmNewPassword;

  GantiPasswordModel({int? id, String? oldPassword, String? newPassword, String? confirmNewPassword})
      : this.id = id ?? 0,
        this.oldPassword = oldPassword ?? '',
        this.newPassword = newPassword ?? '',
        this.confirmNewPassword = confirmNewPassword ?? '';

  GantiPasswordModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];  
    oldPassword = json['oldPassword'];
    newPassword = json['newPassword'];
    // confirmNewPassword = json['confirmNewPassword'];
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['oldPassword'] = this.oldPassword;
    data['newPassword'] = this.newPassword;
    data['confirmNewPassword'] = this.confirmNewPassword;
    return data;
  }
}