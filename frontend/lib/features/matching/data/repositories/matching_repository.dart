import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/match_candidate_model.dart';
import '../models/matching_action_user_model.dart';
import '../models/matching_activity_model.dart';

class MatchingRepository {
  final Dio _dio;

  MatchingRepository(this._dio);

  Future<void> recordAction({
    required int targetUserId,
    required String action,
    required int matchScore,
  }) async {
    final response = await _dio.post(
      ApiConstants.matchingAction,
      data: {
        'targetUserId': targetUserId,
        'action': action,
        'matchScore': matchScore,
      },
    );

    if (response.data['success'] != true) {
      throw Exception('Failed to record matching action');
    }
  }

  Future<MatchingActivityModel> getMyActivity() async {
    final response = await _dio.get(ApiConstants.matchingActivity);
    if (response.data['success'] == true) {
      return MatchingActivityModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load matching activity');
  }

  Future<List<MatchCandidateModel>> getCandidates({
    required int distanceKm,
    int limit = 30,
  }) async {
    final response = await _dio.get(
      ApiConstants.matching,
      queryParameters: {
        'distanceKm': distanceKm,
        'limit': limit,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => MatchCandidateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load matching candidates');
  }

  Future<List<MatchingActionUserModel>> getActionUsers({
    required String action,
    required String direction,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.matchingActions,
      queryParameters: {
        'action': action,
        'direction': direction,
        'limit': limit,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => MatchingActionUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load matching actions');
  }
}
