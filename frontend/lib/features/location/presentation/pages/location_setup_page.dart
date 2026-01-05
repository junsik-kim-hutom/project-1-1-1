import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/location_provider.dart';

class LocationSetupPage extends ConsumerStatefulWidget {
  const LocationSetupPage({super.key});

  @override
  ConsumerState<LocationSetupPage> createState() => _LocationSetupPageState();
}

class _LocationSetupPageState extends ConsumerState<LocationSetupPage> {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  int _selectedRadius = 10000; // 10km in meters

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMyAreas();
  }

  Future<void> _loadMyAreas() async {
    await ref.read(locationProvider.notifier).loadMyAreas();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _currentAddress = '${place.locality}, ${place.administrativeArea}, ${place.country}';
          });
        }
      } catch (e) {
        debugPrint('Failed to get address: $e');
      }

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 가져오기 실패: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLocation() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 위치를 확인해주세요')),
      );
      return;
    }

    final locationState = ref.read(locationProvider);
    if (locationState.areas.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최대 2개의 지역만 등록할 수 있습니다')),
      );
      return;
    }

    final success = await ref.read(locationProvider.notifier).createArea(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          address: _currentAddress ?? '주소 정보 없음',
          radius: _selectedRadius,
          isPrimary: locationState.areas.isEmpty,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치가 저장되었습니다')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      final error = ref.read(locationProvider).error ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 설정'),
      ),
      body: _isLoading || locationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current location card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '현재 위치',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_currentPosition != null) ...[
                          if (_currentAddress != null) ...[
                            Text(
                              _currentAddress!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            '위도: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '경도: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ] else ...[
                          const Text('위치 정보를 가져올 수 없습니다'),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('위치 새로고침'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Radius selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '검색 반경',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildRadiusChip('10km', 10000),
                            _buildRadiusChip('20km', 20000),
                            _buildRadiusChip('30km', 30000),
                            _buildRadiusChip('40km', 40000),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '위치 정보 안내',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• 최대 2개의 활동 지역을 설정할 수 있습니다\n'
                          '• 위치는 30일마다 재인증이 필요합니다\n'
                          '• 정확한 위치가 아닌 반경 내에서만 표시됩니다',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _saveLocation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('위치 저장'),
                ),
              ],
            ),
    );
  }

  Widget _buildRadiusChip(String label, int radius) {
    final isSelected = _selectedRadius == radius;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRadius = radius;
          });
        }
      },
    );
  }
}
