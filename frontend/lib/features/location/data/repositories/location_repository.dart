import 'package:dio/dio.dart';

// 커스텀 예외 클래스
class LocationAreaLimitException implements Exception {
  final String message;
  LocationAreaLimitException(this.message);

  @override
  String toString() => message;
}

class LocationArea {
  final int? id;
  final double latitude;
  final double longitude;
  final String address;
  final int radius;
  final bool isPrimary;
  final DateTime? verifiedAt;

  LocationArea({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.radius,
    this.isPrimary = false,
    this.verifiedAt,
  });

  factory LocationArea.fromJson(Map<String, dynamic> json) {
    return LocationArea(
      id: _parseOptionalId(json['id']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      radius: json['radius'] as int,
      isPrimary: json['isPrimary'] as bool? ?? false,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'radius': radius,
      'isPrimary': isPrimary,
      if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
    };
  }
}

int? _parseOptionalId(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

class LocationRepository {
  final Dio _dio;

  LocationRepository(this._dio);

  /// 지역 등록
  Future<LocationArea> createArea(LocationArea area) async {
    try {
      final response = await _dio.post(
        '/api/location/areas',
        data: area.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LocationArea.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create area: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['error'] ?? e.response?.data['message'];
        if (errorMessage != null && errorMessage.toString().contains('Maximum')) {
          throw LocationAreaLimitException(errorMessage.toString());
        }
        throw Exception(errorMessage ?? 'Invalid request');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// 등록된 지역 목록 조회
  Future<List<LocationArea>> getMyAreas() async {
    try {
      final response = await _dio.get('/api/location/areas');

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List;
        return data.map((json) => LocationArea.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get areas: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['error'] ?? e.response?.data['message'];
        if (errorMessage != null && errorMessage.toString().contains('Maximum')) {
          throw LocationAreaLimitException(errorMessage.toString());
        }
        throw Exception(errorMessage ?? 'Invalid request');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// 지역 수정
  Future<LocationArea> updateArea(int areaId, LocationArea area) async {
    try {
      final response = await _dio.put(
        '/api/location/areas/$areaId',
        data: area.toJson(),
      );

      if (response.statusCode == 200) {
        return LocationArea.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update area: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// 지역 GPS 인증
  Future<void> verifyArea(int areaId, double latitude, double longitude) async {
    try {
      final response = await _dio.post(
        '/api/location/areas/$areaId/verify',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to verify area: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// 지역 삭제
  Future<void> deleteArea(int areaId) async {
    try {
      final response = await _dio.delete('/api/location/areas/$areaId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete area: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// 근처 사용자 검색
  Future<List<Map<String, dynamic>>> findNearbyUsers({
    required double latitude,
    required double longitude,
    int distance = 10000,
  }) async {
    try {
      final response = await _dio.get(
        '/api/location/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'distance': distance,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to find nearby users: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
