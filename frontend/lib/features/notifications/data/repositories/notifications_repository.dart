import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/notification_model.dart';

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository(this._dio);

  Future<List<NotificationModel>> list({
    List<String>? types,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {
        if (types != null && types.isNotEmpty) 'types': types.join(','),
        'limit': limit,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load notifications');
  }
}

