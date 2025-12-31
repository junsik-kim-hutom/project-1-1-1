class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String socketUrl = 'http://localhost:3000';

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

  // Matching endpoints
  static const String matching = '/api/matching';
  static const String balanceGames = '/api/balance-games';

  // Payment endpoints
  static const String payments = '/api/payments';
  static const String subscriptions = '/api/subscriptions';
}
