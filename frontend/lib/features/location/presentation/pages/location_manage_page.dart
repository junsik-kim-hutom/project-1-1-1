import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/google_geocoding_api.dart';
import '../../data/location_label_formatter.dart';
import '../../data/location_query_utils.dart';
import '../../data/repositories/location_repository.dart';
import '../../providers/location_provider.dart';
import 'location_search_page.dart';

class LocationManagePage extends ConsumerStatefulWidget {
  const LocationManagePage({super.key});

  @override
  ConsumerState<LocationManagePage> createState() => _LocationManagePageState();
}

class _LocationManagePageState extends ConsumerState<LocationManagePage> {
  static const _defaultCamera =
      CameraPosition(target: LatLng(37.5665, 126.9780), zoom: 12);
  static const _nativeConfigChannel = MethodChannel('app/native_config');

  GoogleMapController? _mapController;
  ProviderSubscription<LocationState>? _locationSubscription;
  int? _selectedAreaId;
  bool _loadingPosition = false;
  Position? _currentPosition;
  bool _mapsConfigured = false;
  String? _googleMapsApiKey;
  final _googleGeocoding = GoogleGeocodingApi();
  final Map<int, String> _localizedAreaLabels = {};
  String? _lastLocaleTag;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('[LocationManage] initState');
    _locationSubscription =
        ref.listenManual<LocationState>(locationProvider, (previous, next) {
      if (!mounted) return;
      if (previous?.areas == next.areas) return;
      _refreshAreaLabels(next.areas);
    });
    Future.microtask(() async {
      await _loadGoogleMapsKey();
      await ref.read(locationProvider.notifier).loadMyAreas();
      _checkForErrors();
      _refreshAreaLabels(ref.read(locationProvider).areas);
    });
    _loadCurrentPosition();
    _checkMapsConfigured();
  }

  @override
  void dispose() {
    _locationSubscription?.close();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tag = Localizations.localeOf(context).toLanguageTag();
    if (_lastLocaleTag != tag) {
      _lastLocaleTag = tag;
      _localizedAreaLabels.clear();
      _refreshAreaLabels(ref.read(locationProvider).areas);
    }
  }

  void _checkForErrors() {
    final state = ref.read(locationProvider);
    if (state.error != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        String errorMessage = state.error!;

        // 최대 개수 제한 오류 메시지를 사용자 친화적으로 변환
        if (errorMessage.contains('Maximum')) {
          errorMessage = l10n.locationMaxTwoAreas;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  Future<void> _checkMapsConfigured() async {
    try {
      final configured = await _nativeConfigChannel
          .invokeMethod<bool>('isGoogleMapsConfigured');
      if (!mounted) return;
      setState(() => _mapsConfigured = configured ?? false);
      if (kDebugMode) {
        debugPrint('[LocationManage] isGoogleMapsConfigured=$configured');
      }
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _mapsConfigured = true); // platforms without native channel
      if (kDebugMode) {
        debugPrint('[LocationManage] isGoogleMapsConfigured check failed: $e');
      }
    }
  }

  Future<void> _loadGoogleMapsKey() async {
    try {
      final key = await _nativeConfigChannel
          .invokeMethod<String>('getGoogleMapsApiKey');
      final trimmed = key?.trim();
      if (!mounted) return;
      setState(() => _googleMapsApiKey =
          (trimmed == null || trimmed.isEmpty) ? null : trimmed);
    } catch (_) {
      // ignore: optional enhancement
    }
  }

  String _localeIdentifier() {
    final locale = Localizations.localeOf(context);
    final country = (locale.countryCode ?? '').trim();
    if (country.isEmpty) return locale.languageCode;
    return '${locale.languageCode}_$country';
  }

  Future<String?> _resolveLabel(double lat, double lng) async {
    final key = _googleMapsApiKey;
    if (key != null && key.isNotEmpty) {
      try {
        final results = await _googleGeocoding.reverseGeocode(
          latitude: lat,
          longitude: lng,
          apiKey: key,
          language: Localizations.localeOf(context).languageCode,
          region: googleRegionForLocale(Localizations.localeOf(context)),
          limit: 1,
        );
        if (results.isNotEmpty) {
          final r = results.first;
          final label =
              (formatNeighborhoodLabelFromGoogleComponents(r.components) ??
                      r.formattedAddress)
                  .trim();
          if (label.isNotEmpty) return label;
        }
      } catch (_) {
        // fallback below
      }
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        lat,
        lng,
        localeIdentifier: _localeIdentifier(),
      );
      if (placemarks.isEmpty) return null;
      return formatNeighborhoodLabelFromPlacemark(placemarks.first);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshAreaLabels(List<LocationArea> areas) async {
    if (!mounted) return;
    if (areas.isEmpty) {
      if (_localizedAreaLabels.isNotEmpty) setState(_localizedAreaLabels.clear);
      return;
    }

    final currentIds = areas.map((a) => a.id).whereType<int>().toSet();
    final staleKeys = _localizedAreaLabels.keys
        .where((k) => !currentIds.contains(k))
        .toList();
    if (staleKeys.isNotEmpty) {
      setState(() {
        for (final k in staleKeys) {
          _localizedAreaLabels.remove(k);
        }
      });
    }

    final pending = <int, Future<String?>>{};
    for (final a in areas) {
      final id = a.id;
      if (id == null) continue;
      if (_localizedAreaLabels.containsKey(id)) continue;
      pending[id] = _resolveLabel(a.latitude, a.longitude);
    }
    if (pending.isEmpty) return;

    final resolved = <int, String>{};
    for (final entry in pending.entries) {
      final label = await entry.value;
      if (!mounted) return;
      if (label != null && label.trim().isNotEmpty) {
        resolved[entry.key] = label.trim();
      }
    }
    if (!mounted) return;
    if (resolved.isEmpty) return;
    setState(() => _localizedAreaLabels.addAll(resolved));
  }

  String _displayAddress(LocationArea area) {
    final id = area.id;
    if (id == null) return area.address;
    return _localizedAreaLabels[id] ?? area.address;
  }

  Future<void> _loadCurrentPosition() async {
    setState(() => _loadingPosition = true);
    try {
      final position = await _requestCurrentPosition(allowLastKnown: true);
      if (!mounted) return;
      setState(() => _currentPosition = position);
      if (kDebugMode) {
        debugPrint(
            '[LocationManage] currentPosition=(${position.latitude}, ${position.longitude})');
      }
    } catch (_) {
      // ignore: keep fallback camera
      if (kDebugMode) {
        debugPrint('[LocationManage] currentPosition load failed');
      }
    } finally {
      if (!mounted) return;
      setState(() => _loadingPosition = false);
    }
  }

  Future<Position> _requestCurrentPosition(
      {required bool allowLastKnown}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        debugPrint('[LocationManage] Location services are disabled');
      }
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (kDebugMode) {
      debugPrint('[LocationManage] Permission status: $permission');
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (kDebugMode) {
        debugPrint('[LocationManage] Permission after request: $permission');
      }
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    if (allowLastKnown) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        if (kDebugMode) {
          debugPrint(
              '[LocationManage] Using lastKnownPosition: (${lastKnown.latitude}, ${lastKnown.longitude})');
          debugPrint(
              '[LocationManage] Position accuracy: ${lastKnown.accuracy}m, age: ${DateTime.now().difference(lastKnown.timestamp)}');
        }
        return lastKnown;
      }
      if (kDebugMode) {
        debugPrint('[LocationManage] No lastKnownPosition available');
      }
    }

    if (kDebugMode) {
      debugPrint('[LocationManage] Requesting current position...');
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
    if (kDebugMode) {
      debugPrint(
          '[LocationManage] Got current position: (${position.latitude}, ${position.longitude})');
      debugPrint(
          '[LocationManage] Position accuracy: ${position.accuracy}m, timestamp: ${position.timestamp}');

      // Check if position is within South Korea bounds (approximately)
      final isInKorea = position.latitude >= 33.0 &&
          position.latitude <= 43.0 &&
          position.longitude >= 124.0 &&
          position.longitude <= 132.0;
      if (!isInKorea) {
        debugPrint(
            '[LocationManage] ⚠️ WARNING: Position is outside South Korea bounds!');
        debugPrint(
            '[LocationManage] This might be emulator default location or incorrect GPS data');
      }
    }
    return position;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = colorScheme.primary;
    final state = ref.watch(locationProvider);
    final areas = state.areas;
    final l10n = AppLocalizations.of(context)!;
    if (kDebugMode) {
      debugPrint(
          '[LocationManage] build areas=${areas.length} loading=${state.isLoading} mapsConfigured=$_mapsConfigured');
    }

    if (_selectedAreaId == null) {
      final primary = areas.where((a) => a.isPrimary && a.id != null).toList();
      if (primary.isNotEmpty) {
        _selectedAreaId = primary.first.id;
      } else {
        _selectedAreaId = areas.map((a) => a.id).whereType<int>().firstOrNull;
      }
    }

    final circles = <Circle>{};
    for (final a in areas) {
      if (a.id == null) continue;
      final isSelected = a.id == _selectedAreaId;
      circles.add(
        Circle(
          circleId: CircleId(a.id!.toString()),
          center: LatLng(a.latitude, a.longitude),
          radius: a.radius.toDouble(),
          fillColor: (isSelected ? accent : colorScheme.onSurface)
              .withValues(alpha: isSelected ? 0.14 : 0.10),
          strokeColor: (isSelected ? accent : colorScheme.onSurface)
              .withValues(alpha: isSelected ? 0.85 : 0.35),
          strokeWidth: isSelected ? 3 : 2,
        ),
      );
    }

    final markers = <Marker>{};
    for (final a in areas) {
      if (a.id == null) continue;
      final isSelected = a.id == _selectedAreaId;
      markers.add(
        Marker(
          markerId: MarkerId(a.id!.toString()),
          position: LatLng(a.latitude, a.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRose,
          ),
          onTap: () => _selectArea(a.id!, a.latitude, a.longitude),
        ),
      );
    }

    final initialCamera = _initialCamera(areas);

    final canShowMap = _mapsConfigured;

    return Scaffold(
      body: Stack(
        children: [
          if (canShowMap)
            GoogleMap(
              initialCameraPosition: initialCamera,
              style: isDark ? _darkMapStyle : null,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              markers: markers,
              circles: circles,
              onMapCreated: (controller) async {
                if (kDebugMode) debugPrint('[LocationManage] map created');
                _mapController = controller;
                _maybeMoveToSelected(areas);
              },
            )
          else
            _MapsNotConfiguredPlaceholder(
              onOpenInfo: () => _showMapsSetupInfo(context),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  _TopIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.locationMyNeighborhoodSettings,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _TopIconButton(
                    icon: Icons.help_outline_rounded,
                    onTap: () => _showHelp(context),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 240,
            child: Column(
              children: [
                _FabButton(
                  icon: Icons.my_location_rounded,
                  onTap: _loadingPosition ? null : _moveToCurrent,
                ),
              ],
            ),
          ),
          _BottomSheet(
            selected: _selectedAreaId,
            areas: areas,
            labelForArea: _displayAddress,
            onSelect: (area) async {
              await _setPrimaryArea(area);
              _selectArea(area.id!, area.latitude, area.longitude);
            },
            onAdd: areas.length >= 2 ? null : () => _addArea(context, areas),
            onEdit: (area) => _editArea(context, area),
            onRemove: (area) => _removeArea(context, area),
          ),
          if (state.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  CameraPosition _initialCamera(List<LocationArea> areas) {
    if (areas.isNotEmpty) {
      final primary =
          areas.firstWhere((a) => a.isPrimary, orElse: () => areas.first);
      return CameraPosition(
        target: LatLng(primary.latitude, primary.longitude),
        zoom: 12.8,
      );
    }
    if (_currentPosition != null) {
      return CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 13,
      );
    }
    return _defaultCamera;
  }

  void _maybeMoveToSelected(List<LocationArea> areas) {
    if (_selectedAreaId == null || _mapController == null) return;
    final selected = areas.where((a) => a.id == _selectedAreaId).toList();
    if (selected.isEmpty) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(selected.first.latitude, selected.first.longitude),
        12.8,
      ),
    );
  }

  Future<void> _moveToCurrent() async {
    setState(() => _loadingPosition = true);
    try {
      final position = await _requestCurrentPosition(allowLastKnown: false);
      if (!mounted) return;
      setState(() => _currentPosition = position);
      if (_mapController == null) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.locationCurrentLocationFailed)),
        );
        return;
      }
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationCurrentLocationFailed)),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loadingPosition = false);
    }
  }

  void _selectArea(int id, double lat, double lng) {
    setState(() => _selectedAreaId = id);
    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 12.8));
  }

  Future<void> _addArea(
      BuildContext context, List<LocationArea> existing) async {
    final result = await Navigator.of(context).push<LocationSearchResult>(
      MaterialPageRoute(builder: (_) => const LocationSearchPage()),
    );
    if (result == null) return;

    final locationState = ref.read(locationProvider);
    if (locationState.areas.length >= 2) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locationMaxTwoAreas),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final success = await ref.read(locationProvider.notifier).createArea(
          latitude: result.latitude,
          longitude: result.longitude,
          address: result.label,
          radius: 10000,
          isPrimary: locationState.areas.isEmpty,
        );

    // 에러가 있으면 표시
    final state = ref.read(locationProvider);
    if (state.error != null) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      String errorMessage = state.error!;

      // 최대 개수 제한 오류 메시지를 사용자 친화적으로 변환
      if (errorMessage.contains('Maximum')) {
        errorMessage = l10n.locationMaxTwoAreas;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (!mounted) return;

    if (!success) return;

    await ref.read(locationProvider.notifier).loadMyAreas();
    final updated = ref.read(locationProvider).areas;
    if (updated.isNotEmpty) {
      final primary =
          updated.firstWhere((a) => a.isPrimary, orElse: () => updated.first);
      if (primary.id != null) {
        _selectArea(primary.id!, primary.latitude, primary.longitude);
      }
    }
  }

  Future<void> _removeArea(BuildContext context, LocationArea area) async {
    if (area.id == null) return;
    final ok = await ref.read(locationProvider.notifier).deleteArea(area.id!);
    if (!ok || !mounted) return;

    final updated = ref.read(locationProvider).areas;
    if (_selectedAreaId == area.id) {
      setState(() {
        _selectedAreaId = updated.isNotEmpty ? updated.first.id : null;
      });
    }
  }

  void _showHelp(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.locationMyNeighborhoodSettings,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.locationHelpBody,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMapsSetupInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.locationMapSetupRequiredTitle,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.locationMapSetupRequiredBody,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _setPrimaryArea(LocationArea selected) async {
    if (selected.id == null) return;
    final current = ref.read(locationProvider).areas;
    final selectedId = selected.id!;
    final toUpdate = <LocationArea>[
      for (final a in current)
        if (a.id != null && (a.id == selectedId ? !a.isPrimary : a.isPrimary))
          a,
    ];
    if (toUpdate.isEmpty) return;

    for (final a in toUpdate) {
      if (a.id == null) continue;
      await ref.read(locationProvider.notifier).updateArea(
            a.id!,
            latitude: a.latitude,
            longitude: a.longitude,
            address: a.address,
            radius: a.radius,
            isPrimary: a.id == selectedId,
          );
    }
    await ref.read(locationProvider.notifier).loadMyAreas();
  }

  Future<void> _editArea(BuildContext context, LocationArea area) async {
    if (area.id == null) return;
    final result = await Navigator.of(context).push<LocationSearchResult>(
      MaterialPageRoute(builder: (_) => const LocationSearchPage()),
    );
    if (result == null) return;

    await ref.read(locationProvider.notifier).updateArea(
          area.id!,
          latitude: result.latitude,
          longitude: result.longitude,
          address: result.label,
          radius: area.radius,
          isPrimary: area.isPrimary,
        );
    await ref.read(locationProvider.notifier).loadMyAreas();
    final updated = ref.read(locationProvider).areas.firstWhere(
          (a) => a.id == area.id,
          orElse: () => area,
        );
    if (updated.id != null) {
      _selectArea(updated.id!, updated.latitude, updated.longitude);
    }
  }
}

class _BottomSheet extends StatelessWidget {
  final int? selected;
  final List<LocationArea> areas;
  final String Function(LocationArea area) labelForArea;
  final ValueChanged<LocationArea> onSelect;
  final VoidCallback? onAdd;
  final ValueChanged<LocationArea> onEdit;
  final ValueChanged<LocationArea> onRemove;

  const _BottomSheet({
    required this.selected,
    required this.areas,
    this.labelForArea = _defaultLabelForArea,
    required this.onSelect,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  static String _defaultLabelForArea(LocationArea area) => area.address;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: colorScheme.outline
                    .withValues(alpha: isDark ? 0.65 : 0.35)),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black54 : Colors.black12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.locationMyNeighborhood,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.locationMyNeighborhoodSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < areas.length; i++) ...[
                    _AreaChip(
                      label: _shortLabel(labelForArea(areas[i])),
                      selected: areas[i].id != null && areas[i].id == selected,
                      onTap: () => onSelect(areas[i]),
                      onLongPress: () => onEdit(areas[i]),
                      onRemove: () => onRemove(areas[i]),
                    ),
                    if (i != areas.length - 1 || onAdd != null)
                      const SizedBox(width: 10),
                  ],
                  if (onAdd != null)
                    Expanded(
                      child: _AddChip(
                        enabled: true,
                        onTap: onAdd,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _shortLabel(String address) {
    return shortLocationLabel(address, maxParts: 2);
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;

  const _AreaChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? accent : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? accent
                  : colorScheme.outline.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkResponse(
                onTap: onRemove,
                radius: 18,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _AddChip({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.7)),
        ),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            color:
                enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: isDark ? 0.72 : 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color:
                  colorScheme.outline.withValues(alpha: isDark ? 0.65 : 0.35)),
        ),
        child: Icon(icon, color: colorScheme.onSurface),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _FabButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: isDark ? 0.8 : 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  colorScheme.outline.withValues(alpha: isDark ? 0.7 : 0.35)),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black54 : Colors.black12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onSurface),
      ),
    );
  }
}

// Basic dark map style (no external assets).
const _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d2230"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a93a6"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d2230"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#30384d"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#8a93a6"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#182033"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a3247"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1b2130"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#7f889c"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2a3247"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#111827"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#67718a"}]}
]
''';

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _MapsNotConfiguredPlaceholder extends StatelessWidget {
  final VoidCallback onOpenInfo;

  const _MapsNotConfiguredPlaceholder({required this.onOpenInfo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined,
                  color: colorScheme.onSurfaceVariant, size: 52),
              const SizedBox(height: 14),
              Text(
                l10n.locationMapCannotShowTitle,
                style: AppTextStyles.titleLarge.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.locationMapCannotShowBody,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onOpenInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.locationViewSetupGuide),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
