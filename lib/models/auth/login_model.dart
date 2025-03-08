



import 'package:biphip_messenger/models/common/common_user_model.dart';

class LoginModel {
  User user;
  dynamic token;

  LoginModel({
    required this.user,
    required this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        user: User.fromJson(json["user"]),
        token: json["token"],
      );
}