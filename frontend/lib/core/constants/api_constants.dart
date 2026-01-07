import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _defaultLocalhost = 'http://localhost:3000';
  static const String _androidEmulatorHost = 'http://10.0.2.2:3000';

  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _envSocketUrl = String.fromEnvironment('SOCKET_URL');

  static String get baseUrl {
    if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;

    // Android emulator cannot reach host machine via localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorHost;
    }

    return _defaultLocalhost;
  }

  static String get socketUrl {
    if (_envSocketUrl.isNotEmpty) return _envSocketUrl;
    return baseUrl;
  }

  // Auth endpoints
  static const String authGoogle = '/api/auth/google';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';

  // Profile endpoints
  static const String profileCreate = '/api/profile';
  static const String profileUpdate = '/api/profile';
  static const String profileMe = '/api/profile/me';
  static String profileById(String userId) => '/api/profile/$userId';

  // Chat endpoints
  static const String chatRooms = '/api/chat/rooms';
  static String chatMessages(String roomId) => '/api/chat/rooms/$roomId/messages';
  static const String chatDirectRoom = '/api/chat/rooms/direct';
  static String chatMarkRead(String roomId) => '/api/chat/rooms/$roomId/read';
  static String chatDeleteAllMessages(String roomId) => '/api/chat/rooms/$roomId/messages';
  static String chatDeleteMessage(String messageId) => '/api/chat/messages/$messageId';

  // Matching endpoints
  static const String matching = '/api/matching';
  static const String matchingAction = '/api/matching/action';
  static const String matchingActivity = '/api/matching/activity';
  static const String matchingActions = '/api/matching/actions';
  static const String balanceGames = '/api/balance-games';

  // Payment endpoints
  static const String payments = '/api/payments';
  static const String subscriptions = '/api/subscriptions';

  // Notifications endpoints
  static const String notifications = '/api/notifications';

  // EQ Test endpoints
  static const String eqTestQuestions = '/api/eq-test/questions';
  static const String eqTestAnswers = '/api/eq-test/answers';
  static const String eqTestResultsCalculate = '/api/eq-test/results/calculate';
  static const String eqTestResults = '/api/eq-test/results';
}
