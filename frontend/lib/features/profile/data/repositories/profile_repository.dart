import 'package:dio/dio.dart';
import '../../../../core/models/profile_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Map<String, dynamic> _normalizeProfileData(Map<String, dynamic> profileData) {
    final normalized = Map<String, dynamic>.from(profileData);

    final imagesRaw = normalized['profileImages'];
    if (imagesRaw is List) {
      final images = imagesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();

      final explicitIndexRaw = normalized.remove('mainProfileImageIndex') ??
          normalized.remove('mainImageIndex');
      final explicitUrlRaw = normalized.remove('mainProfileImageUrl') ??
          normalized.remove('mainImageUrl');

      int? mainIndex;
      if (explicitIndexRaw is int) {
        mainIndex = explicitIndexRaw;
      } else if (explicitIndexRaw is String) {
        mainIndex = int.tryParse(explicitIndexRaw);
      } else if (explicitUrlRaw != null) {
        final explicitUrl = explicitUrlRaw.toString();
        final index = images.indexOf(explicitUrl);
        if (index >= 0) mainIndex = index;
      }

      if (mainIndex != null && images.isNotEmpty && mainIndex >= 0 && mainIndex < images.length) {
        final mainUrl = images[mainIndex];
        normalized['profileImages'] = <String>[
          mainUrl,
          for (var i = 0; i < images.length; i++) if (i != mainIndex) images[i],
        ];
      } else {
        normalized['profileImages'] = images;
      }
    }

    return normalized;
  }

  /// 프로필 생성
  Future<ProfileModel> createProfile(Map<String, dynamic> profileData) async {
    try {
      final payload = _normalizeProfileData(profileData);
      print('[PROFILE_REPO] Creating profile with data: $payload');
      final response = await _dio.post(
        '/api/profile',
        data: payload,
      );

      print('[PROFILE_REPO] Response status: ${response.statusCode}');
      print('[PROFILE_REPO] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('[PROFILE_REPO] DioException occurred:');
      print('[PROFILE_REPO] - Status code: ${e.response?.statusCode}');
      print('[PROFILE_REPO] - Response data: ${e.response?.data}');
      print('[PROFILE_REPO] - Error message: ${e.message}');

      if (e.response?.data != null) {
        final errorMessage = e.response?.data['error'] ?? e.message;
        throw Exception('Profile creation error: $errorMessage');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('[PROFILE_REPO] Unexpected error: $e');
      rethrow;
    }
  }

  /// 프로필 수정
  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final payload = _normalizeProfileData(profileData);
      print('[PROFILE_REPO] Updating profile with data: $payload');
      final response = await _dio.put(
        '/api/profile',
        data: payload,
      );

      print('[PROFILE_REPO] Response status: ${response.statusCode}');
      print('[PROFILE_REPO] Response data: ${response.data}');

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('[PROFILE_REPO] DioException occurred:');
      print('[PROFILE_REPO] - Status code: ${e.response?.statusCode}');
      print('[PROFILE_REPO] - Response data: ${e.response?.data}');
      print('[PROFILE_REPO] - Error message: ${e.message}');

      if (e.response?.data != null) {
        final errorMessage = e.response?.data['error'] ?? e.message;
        throw Exception('Profile update error: $errorMessage');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('[PROFILE_REPO] Unexpected error: $e');
      rethrow;
    }
  }

  /// 내 프로필 조회
  Future<ProfileModel> getMyProfile() async {
    try {
      final response = await _dio.get('/api/profile/me');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('PROFILE_NOT_FOUND');
        }
        return ProfileModel.fromJson(data);
      } else {
        throw Exception('Failed to get profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('PROFILE_NOT_FOUND');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('PROFILE_NOT_FOUND')) {
        throw Exception('PROFILE_NOT_FOUND');
      }
      throw Exception('Failed to get profile');
    }
  }

  /// 특정 사용자 프로필 조회
  Future<ProfileModel> getProfileById(String userId) async {
    try {
      final response = await _dio.get('/api/profile/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('PROFILE_NOT_FOUND');
        }
        return ProfileModel.fromJson(data);
      } else {
        throw Exception('Failed to get profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('PROFILE_NOT_FOUND');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('PROFILE_NOT_FOUND')) {
        throw Exception('PROFILE_NOT_FOUND');
      }
      throw Exception('Failed to get profile');
    }
  }

  /// 프로필 삭제
  Future<void> deleteProfile() async {
    try {
      final response = await _dio.delete('/api/profile');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
