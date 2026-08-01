import 'user_model.dart';

class LoginResponseModel {
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  LoginResponseModel({
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
    };
  }
}
