import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/match_candidate_model.dart';
import '../../data/models/matching_action_user_model.dart';
import '../../data/models/matching_activity_model.dart';
import '../../data/repositories/matching_repository.dart';

final matchingRepositoryProvider = Provider<MatchingRepository>((ref) {
  return MatchingRepository(ref.watch(dioProvider));
});

class MatchingQuery {
  final int distanceKm;
  final int limit;

  const MatchingQuery({
    required this.distanceKm,
    this.limit = 30,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchingQuery &&
          runtimeType == other.runtimeType &&
          distanceKm == other.distanceKm &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(distanceKm, limit);
}

final matchingCandidatesProvider =
    FutureProvider.autoDispose.family<List<MatchCandidateModel>, MatchingQuery>((ref, query) async {
  final repo = ref.watch(matchingRepositoryProvider);
  return repo.getCandidates(distanceKm: query.distanceKm, limit: query.limit);
});

final matchingActivityProvider = FutureProvider<MatchingActivityModel>((ref) async {
  final repo = ref.watch(matchingRepositoryProvider);
  return repo.getMyActivity();
});

class MatchingActionUsersQuery {
  final String action;
  final String direction;
  final int limit;

  const MatchingActionUsersQuery({
    required this.action,
    required this.direction,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchingActionUsersQuery &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          direction == other.direction &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(action, direction, limit);
}

final matchingActionUsersProvider = FutureProvider.autoDispose
    .family<List<MatchingActionUserModel>, MatchingActionUsersQuery>((ref, query) async {
  final repo = ref.watch(matchingRepositoryProvider);
  return repo.getActionUsers(action: query.action, direction: query.direction, limit: query.limit);
});
