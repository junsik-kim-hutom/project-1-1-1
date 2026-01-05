import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/providers/dio_provider.dart';
import '../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _profileRepository;
  bool _isLoading = false;
  bool _hasAttemptedLoad = false;

  ProfileNotifier(this._profileRepository) : super(ProfileState());

  /// 프로필 생성
  Future<bool> createProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _profileRepository.createProfile(profileData);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 프로필 수정
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _profileRepository.updateProfile(profileData);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 내 프로필 조회
  Future<void> loadMyProfile({bool force = false}) async {
    if (_isLoading) return;
    if (_hasAttemptedLoad && !force) return;
    if (!force && state.error?.contains('PROFILE_NOT_FOUND') == true) {
      return;
    }

    _hasAttemptedLoad = true;
    _isLoading = true;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _profileRepository.getMyProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// 특정 사용자 프로필 조회
  Future<void> loadProfileById(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _profileRepository.getProfileById(userId);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 프로필 삭제
  Future<bool> deleteProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _profileRepository.deleteProfile();
      state = ProfileState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(profileRepository);
});
