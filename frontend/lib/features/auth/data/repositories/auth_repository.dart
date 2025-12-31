import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_response_model.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<LoginResponseModel> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.authGoogle,
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return LoginResponseModel.fromJson(data);
      } else {
        throw Exception('Google login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Google login failed: ${e.response?.data['message'] ?? e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.authLogout);
    } catch (e) {
      // Continue with local logout even if server request fails
    } finally {
      await deleteTokens();
    }
  }
}
