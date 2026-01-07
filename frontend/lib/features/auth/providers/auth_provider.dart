import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/secure_storage_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/login_response_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool? hasProfile;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.hasProfile,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? hasProfile,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasProfile: hasProfile ?? this.hasProfile,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState());

  Future<void> checkAuthStatus() async {
    print('[AUTH_PROVIDER] checkAuthStatus called');
    state = state.copyWith(isLoading: true);
    try {
      final accessToken = await _authRepository.getAccessToken();
      print('[AUTH_PROVIDER] Access token exists: ${accessToken != null}');

      if (accessToken != null) {
        var hasProfile = await _authRepository.getHasProfile();
        print('[AUTH_PROVIDER] hasProfile from storage: $hasProfile');

        // If hasProfile is null or false, verify with backend to avoid stale state.
        if (hasProfile != true) {
          print(
              '[AUTH_PROVIDER] hasProfile is not true, verifying with backend');
          try {
            hasProfile = await _authRepository.checkProfileFromBackend();
            print('[AUTH_PROVIDER] hasProfile from backend: $hasProfile');

            // Save to storage for next time
            await _authRepository.saveTokens(
              accessToken,
              await _authRepository.getRefreshToken() ?? '',
              hasProfile: hasProfile,
            );
            print('[AUTH_PROVIDER] Saved hasProfile to storage: $hasProfile');
          } catch (e) {
            print(
                '[AUTH_PROVIDER] Failed to fetch hasProfile from backend: $e');
            // Keep existing value if backend call fails.
            hasProfile ??= null;
          }
        }

        state = state.copyWith(
          isAuthenticated: true,
          hasProfile: hasProfile,
          isLoading: false,
        );
        print(
            '[AUTH_PROVIDER] State updated - isAuthenticated: true, hasProfile: $hasProfile');
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          hasProfile: null,
          isLoading: false,
        );
        print('[AUTH_PROVIDER] State updated - isAuthenticated: false');
      }
    } catch (e) {
      print('[AUTH_PROVIDER] Error in checkAuthStatus: $e');
      state = state.copyWith(
        isAuthenticated: false,
        hasProfile: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<LoginResponseModel?> googleLogin(String idToken) async {
    print('[AUTH_PROVIDER] googleLogin called');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authRepository.googleLogin(idToken);
      print(
          '[AUTH_PROVIDER] Login response received - hasProfile: ${response.hasProfile}');

      await _authRepository.saveTokens(
        response.accessToken,
        response.refreshToken,
        hasProfile: response.hasProfile,
      );
      print(
          '[AUTH_PROVIDER] Tokens saved with hasProfile: ${response.hasProfile}');

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        hasProfile: response.hasProfile,
        isLoading: false,
      );
      print(
          '[AUTH_PROVIDER] State updated with hasProfile: ${response.hasProfile}');

      return response;
    } catch (e) {
      print('[AUTH_PROVIDER] Error in googleLogin: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
        hasProfile: null,
      );
      return null;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.logout();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateHasProfile(bool hasProfile) async {
    print('[AUTH_PROVIDER] updateHasProfile called with: $hasProfile');
    await _authRepository.saveTokens(
      await _authRepository.getAccessToken() ?? '',
      await _authRepository.getRefreshToken() ?? '',
      hasProfile: hasProfile,
    );
    state = state.copyWith(hasProfile: hasProfile);
    print('[AUTH_PROVIDER] hasProfile updated in state: ${state.hasProfile}');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
