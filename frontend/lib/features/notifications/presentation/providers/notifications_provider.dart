import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(dioProvider));
});

class NotificationsQuery {
  final List<String> types;
  final int limit;

  const NotificationsQuery({
    required this.types,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsQuery &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          _listEquals(types, other.types);

  @override
  int get hashCode => Object.hash(limit, Object.hashAll(types));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

final notificationsListProvider = FutureProvider.autoDispose
    .family<List<NotificationModel>, NotificationsQuery>((ref, query) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.list(types: query.types, limit: query.limit);
});

