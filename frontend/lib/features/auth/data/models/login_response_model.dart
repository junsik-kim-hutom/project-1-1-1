import '../../../../core/models/user_model.dart';

class LoginResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  LoginResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      isNewUser: json['isNewUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'isNewUser': isNewUser,
    };
  }
}
