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
      print('[AUTH_REPO] Sending Google login request');
      final response = await _dio.post(
        ApiConstants.authGoogle,
        data: {'idToken': idToken},
      );

      print('[AUTH_REPO] Response status: ${response.statusCode}');
      print('[AUTH_REPO] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        print('[AUTH_REPO] Login response data: $data');
        print('[AUTH_REPO] hasProfile from server: ${data['hasProfile']}');

        final loginResponse = LoginResponseModel.fromJson(data);
        print('[AUTH_REPO] LoginResponseModel hasProfile: ${loginResponse.hasProfile}');

        return loginResponse;
      } else {
        throw Exception('Google login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('[AUTH_REPO] DioException: ${e.message}');
      if (e.response != null) {
        print('[AUTH_REPO] Error response: ${e.response?.data}');
        throw Exception('Google login failed: ${e.response?.data['message'] ?? e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken, {bool? hasProfile}) async {
    print('[AUTH_REPO] saveTokens called with hasProfile: $hasProfile');
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    if (hasProfile != null) {
      await _storage.write(key: 'has_profile', value: hasProfile.toString());
      print('[AUTH_REPO] Saved has_profile to storage: ${hasProfile.toString()}');
    } else {
      print('[AUTH_REPO] hasProfile is null, not saving to storage');
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<bool?> getHasProfile() async {
    final value = await _storage.read(key: 'has_profile');
    print('[AUTH_REPO] getHasProfile - raw value from storage: $value');
    if (value == null) {
      print('[AUTH_REPO] getHasProfile returning null (no value in storage)');
      return null;
    }
    final result = value == 'true';
    print('[AUTH_REPO] getHasProfile returning: $result');
    return result;
  }

  Future<bool> checkProfileFromBackend() async {
    try {
      print('[AUTH_REPO] Calling backend to check profile');
      final response = await _dio.get('/api/profile/check');

      print('[AUTH_REPO] Profile check response: ${response.data}');

      if (response.statusCode == 200) {
        final hasProfile = response.data['data']['hasProfile'] as bool;
        print('[AUTH_REPO] hasProfile from backend: $hasProfile');
        return hasProfile;
      } else {
        throw Exception('Failed to check profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('[AUTH_REPO] DioException in checkProfileFromBackend: ${e.message}');
      if (e.response != null) {
        print('[AUTH_REPO] Error response: ${e.response?.data}');
      }
      throw Exception('Failed to check profile from backend: ${e.message}');
    }
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'has_profile');
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
