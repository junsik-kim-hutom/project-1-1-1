import '../../../../core/models/user_model.dart';

class LoginResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final bool hasProfile;

  LoginResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.hasProfile,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      isNewUser: json['isNewUser'],
      hasProfile: json['hasProfile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'isNewUser': isNewUser,
      'hasProfile': hasProfile,
    };
  }
}
