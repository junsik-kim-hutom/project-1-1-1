import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../data/repositories/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LocationRepository(dio);
});

class LocationState {
  final List<LocationArea> areas;
  final bool isLoading;
  final String? error;

  LocationState({
    this.areas = const [],
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    List<LocationArea>? areas,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      areas: areas ?? this.areas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository _locationRepository;

  LocationNotifier(this._locationRepository) : super(LocationState());

  /// 지역 등록
  Future<bool> createArea({
    required double latitude,
    required double longitude,
    required String address,
    required int radius,
    bool isPrimary = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final area = LocationArea(
        latitude: latitude,
        longitude: longitude,
        address: address,
        radius: radius,
        isPrimary: isPrimary,
      );

      final createdArea = await _locationRepository.createArea(area);
      state = state.copyWith(
        areas: [...state.areas, createdArea],
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

  /// 내 지역 목록 조회
  Future<void> loadMyAreas() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final areas = await _locationRepository.getMyAreas();
      state = state.copyWith(
        areas: areas,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 지역 수정
  Future<bool> updateArea(
    String areaId, {
    required double latitude,
    required double longitude,
    required String address,
    required int radius,
    bool isPrimary = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final area = LocationArea(
        id: areaId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        radius: radius,
        isPrimary: isPrimary,
      );

      final updatedArea = await _locationRepository.updateArea(areaId, area);
      state = state.copyWith(
        areas: state.areas
            .map((a) => a.id == areaId ? updatedArea : a)
            .toList(),
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

  /// 지역 GPS 인증
  Future<bool> verifyArea(String areaId, double latitude, double longitude) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _locationRepository.verifyArea(areaId, latitude, longitude);
      await loadMyAreas(); // 재조회
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 지역 삭제
  Future<bool> deleteArea(String areaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _locationRepository.deleteArea(areaId);
      state = state.copyWith(
        areas: state.areas.where((a) => a.id != areaId).toList(),
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
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final locationRepository = ref.watch(locationRepositoryProvider);
  return LocationNotifier(locationRepository);
});
