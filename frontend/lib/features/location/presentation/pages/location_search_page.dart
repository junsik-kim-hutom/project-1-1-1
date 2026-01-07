import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/google_geocoding_api.dart';
import '../../data/location_label_formatter.dart';
import '../../data/location_query_utils.dart';

class LocationSearchResult {
  final double latitude;
  final double longitude;
  final String label;

  const LocationSearchResult({
    required this.latitude,
    required this.longitude,
    required this.label,
  });
}

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  static const _nativeConfigChannel = MethodChannel('app/native_config');
  static final _random = Random();

  final _controller = TextEditingController();
  Timer? _debounce;

  bool _isSearching = false;
  bool _isLoadingNearby = false;

  List<LocationSearchResult> _nearby = const [];
  List<LocationSearchResult> _results = const [];
  String? _error;

  final _googleGeocoding = GoogleGeocodingApi();
  String? _googleMapsApiKey;
  int _searchGeneration = 0;
  final Map<String, _ReverseGeocodeData> _reverseCache = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadGoogleMapsKey();
      await _loadNearby();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNearby() async {
    setState(() {
      _isLoadingNearby = true;
      _error = null;
    });

    try {
      _switchToNearbyMode();
      final position = await _getCurrentPosition();
      final candidates = await _reverseGeocodeCluster(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _nearby = candidates;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '${AppLocalizations.of(context)!.locationCurrentLocationFailed} $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingNearby = false;
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  }

  Future<void> _onQueryChanged(String value) async {
    if (mounted) setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final query = value.trim();
      final generation = ++_searchGeneration;
      if (!mounted) return;
      if (query.isEmpty) {
        setState(() {
          _results = const [];
          _isSearching = false;
          _error = null;
        });
        return;
      }

      setState(() {
        _isSearching = true;
        _error = null;
      });

      try {
        final key = _googleMapsApiKey;
        List<LocationSearchResult> baseResults;
        if (key != null && key.isNotEmpty) {
          try {
            final googleResults = await _googleGeocoding.geocodeAddress(
              address: query,
              apiKey: key,
              language: _googleLanguage(),
              region: googleRegionForLocale(Localizations.localeOf(context)),
              limit: 10,
            );
            baseResults = [
              for (final r in googleResults)
                LocationSearchResult(
                  latitude: r.location.lat,
                  longitude: r.location.lng,
                  label: () {
                    final label =
                        (formatNeighborhoodLabelFromGoogleComponents(r.components) ?? r.formattedAddress).trim();
                    return label.isEmpty ? query : label;
                  }(),
                ),
            ];
          } catch (_) {
            final localeIdentifier = _localeIdentifier();
            final locations = await locationFromAddress(query, localeIdentifier: localeIdentifier);
            final limited = locations.take(10).toList();
            baseResults = await _formatLocations(limited, fallbackLabel: query);
          }
        } else {
          final localeIdentifier = _localeIdentifier();
          final locations = await locationFromAddress(query, localeIdentifier: localeIdentifier);
          final limited = locations.take(10).toList();
          baseResults = await _formatLocations(limited, fallbackLabel: query);
        }

        var unique = _uniqueByLabel(baseResults);

        if (unique.length <= 1) {
          final expanded = await _expandAdministrativeQuery(
            query: query,
            generation: generation,
          );
          if (expanded.isNotEmpty) {
            unique = _uniqueByLabel([...expanded, ...unique]);
          }
        }

        if (!mounted || generation != _searchGeneration) return;
        setState(() => _results = unique.take(30).toList());
      } catch (e) {
        if (!mounted || generation != _searchGeneration) return;
        setState(() {
          _error = '${AppLocalizations.of(context)!.locationSearchFailed} $e';
          _results = const [];
        });
      } finally {
        if (!mounted || generation != _searchGeneration) return;
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _loadGoogleMapsKey() async {
    try {
      final key = await _nativeConfigChannel.invokeMethod<String>('getGoogleMapsApiKey');
      final trimmed = key?.trim();
      if (!mounted) return;
      setState(() => _googleMapsApiKey = (trimmed == null || trimmed.isEmpty) ? null : trimmed);
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

  String _googleLanguage() => Localizations.localeOf(context).languageCode;

  bool _looksLikeAdministrativeQuery(String query) {
    return looksLikeAdministrativeQuery(query, Localizations.localeOf(context));
  }

  Future<List<LocationSearchResult>> _formatLocations(
    List<Location> locations, {
    required String fallbackLabel,
  }) async {
    final results = <LocationSearchResult>[];
    // keep concurrency modest to avoid platform geocoder throttling
    const batchSize = 4;
    for (var i = 0; i < locations.length; i += batchSize) {
      final batch = locations.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(
        batch.map((loc) async {
          final label = await _formatAddress(loc.latitude, loc.longitude) ?? fallbackLabel;
          return LocationSearchResult(
            latitude: loc.latitude,
            longitude: loc.longitude,
            label: label,
          );
        }),
      );
      results.addAll(batchResults);
    }
    return results;
  }

  Future<String?> _formatAddress(double lat, double lng) async {
    try {
      final p = await _bestPlacemark(lat, lng);
      if (p == null) return null;
      return formatNeighborhoodLabelFromPlacemark(p);
    } catch (_) {
      return null;
    }
  }

  Future<Placemark?> _bestPlacemark(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(
      lat,
      lng,
      localeIdentifier: _localeIdentifier(),
    );
    if (placemarks.isEmpty) return null;

    int score(Placemark p) {
      var s = 0;
      if ((p.subLocality ?? '').trim().isNotEmpty) s += 10;
      if ((p.locality ?? '').trim().isNotEmpty) s += 6;
      if ((p.thoroughfare ?? '').trim().isNotEmpty) s += 3;
      if ((p.name ?? '').trim().isNotEmpty) s += 1;
      return s;
    }

    Placemark best = placemarks.first;
    var bestScore = score(best);
    for (final p in placemarks.skip(1)) {
      final s = score(p);
      if (s > bestScore) {
        best = p;
        bestScore = s;
      }
    }
    return best;
  }

  String _areaKeyFromPlacemark(Placemark p) {
    final admin = (p.administrativeArea ?? '').trim();
    final subAdmin = (p.subAdministrativeArea ?? '').trim();
    return '$admin|$subAdmin';
  }

  String _reverseCacheKey(double lat, double lng) {
    // Round to reduce cache fragmentation from jitter.
    final rLat = (lat * 1e5).round() / 1e5;
    final rLng = (lng * 1e5).round() / 1e5;
    final locale = Localizations.localeOf(context);
    return '${locale.toLanguageTag()}|$rLat,$rLng';
  }

  Future<_ReverseGeocodeData?> _reverseGeocode(double lat, double lng) async {
    final key = _googleMapsApiKey;
    if (key == null || key.isEmpty) return null;

    final cacheKey = _reverseCacheKey(lat, lng);
    final cached = _reverseCache[cacheKey];
    if (cached != null) return cached;

    try {
      final results = await _googleGeocoding.reverseGeocode(
        latitude: lat,
        longitude: lng,
        apiKey: key,
        language: _googleLanguage(),
        region: googleRegionForLocale(Localizations.localeOf(context)),
        limit: 1,
      );
      if (results.isEmpty) return null;

      final r = results.first;
      final label = (formatNeighborhoodLabelFromGoogleComponents(r.components) ?? '').trim();
      final finalLabel = label.isNotEmpty ? label : r.formattedAddress.trim();
      if (finalLabel.isEmpty) return null;

      final out = _ReverseGeocodeData(
        label: finalLabel,
        areaKey: googleAreaKeyFromComponents(r.components),
      );
      _reverseCache[cacheKey] = out;
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<LocationSearchResult>> _expandAdministrativeQuery({
    required String query,
    required int generation,
  }) async {
    if (!_looksLikeAdministrativeQuery(query)) return const [];
    final key = _googleMapsApiKey;
    if (key == null || key.isEmpty) return const [];

    GoogleViewport? viewport;
    try {
      viewport = await _googleGeocoding.geocodeViewport(
        address: query,
        apiKey: key,
        language: _googleLanguage(),
        region: googleRegionForLocale(Localizations.localeOf(context)),
      );
    } catch (_) {
      return const [];
    }

    if (!mounted || generation != _searchGeneration) return const [];
    if (viewport == null) return const [];

    // Avoid sampling huge areas (e.g., an entire city/province)
    if (viewport.latSpan > 0.45 || viewport.lngSpan > 0.45) return const [];

    final center = viewport.center;
    String? expectedAreaKey;
    try {
      final centerReverse = await _reverseGeocode(center.lat, center.lng);
      expectedAreaKey = centerReverse?.areaKey;
    } catch (_) {
      expectedAreaKey = null;
    }
    if (!mounted || generation != _searchGeneration) return const [];
    if (expectedAreaKey == null) {
      Placemark? centerPlacemark;
      try {
        centerPlacemark = await _bestPlacemark(center.lat, center.lng);
      } catch (_) {
        centerPlacemark = null;
      }
      if (!mounted || generation != _searchGeneration) return const [];
      expectedAreaKey = centerPlacemark == null ? null : _areaKeyFromPlacemark(centerPlacemark);
    }
    final locale = Localizations.localeOf(context);

    final points = _sampleViewportPoints(viewport, maxPoints: 36);
    final candidates = <LocationSearchResult>[];

    const batchSize = 4;
    for (var i = 0; i < points.length; i += batchSize) {
      final batch = points.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(
        batch.map((p) async {
          final reverse = await _reverseGeocode(p.$1, p.$2);
          if (reverse != null) {
            if (expectedAreaKey != null && reverse.areaKey != expectedAreaKey) return null;
            if (!labelMatchesQuery(reverse.label, query, locale)) return null;
            return LocationSearchResult(latitude: p.$1, longitude: p.$2, label: reverse.label);
          }

          Placemark? pm;
          try {
            pm = await _bestPlacemark(p.$1, p.$2);
          } catch (_) {
            pm = null;
          }
          if (pm == null) return null;

          if (expectedAreaKey != null && _areaKeyFromPlacemark(pm) != expectedAreaKey) return null;

          final label = formatNeighborhoodLabelFromPlacemark(pm);
          if (label == null || label.trim().isEmpty) return null;

          // If user typed a district name, keep results that include it.
          if (!labelMatchesQuery(label, query, locale)) return null;

          return LocationSearchResult(latitude: p.$1, longitude: p.$2, label: label);
        }),
      );
      for (final r in batchResults) {
        if (r != null) candidates.add(r);
      }
      if (!mounted || generation != _searchGeneration) return const [];
      if (_uniqueByLabel(candidates).length >= 25) break;
    }

    final unique = _uniqueByLabel(candidates);
    unique.sort((a, b) => a.label.compareTo(b.label));
    return unique.take(30).toList();
  }

  List<(double, double)> _sampleViewportPoints(GoogleViewport viewport, {required int maxPoints}) {
    final latMin = min(viewport.southwest.lat, viewport.northeast.lat);
    final latMax = max(viewport.southwest.lat, viewport.northeast.lat);
    final lngMin = min(viewport.southwest.lng, viewport.northeast.lng);
    final lngMax = max(viewport.southwest.lng, viewport.northeast.lng);

    // Prefer a modest grid; larger areas will be rejected earlier.
    const grid = 6; // 36 points
    final points = <(double, double)>[];
    for (var r = 0; r < grid; r++) {
      for (var c = 0; c < grid; c++) {
        final latT = (r + 0.5) / grid;
        final lngT = (c + 0.5) / grid;
        var lat = latMin + (latMax - latMin) * latT;
        var lng = lngMin + (lngMax - lngMin) * lngT;

        // Tiny random jitter to avoid hitting the same boundary lines repeatedly.
        lat += (viewport.latSpan / 300) * (_random.nextDouble() - 0.5);
        lng += (viewport.lngSpan / 300) * (_random.nextDouble() - 0.5);

        points.add((lat, lng));
      }
    }
    points.shuffle(_random);
    return points.take(maxPoints).toList();
  }

  Future<List<LocationSearchResult>> _reverseGeocodeCluster(double lat, double lng) async {
    // Sample points around the user to collect multiple neighboring "동네" entries.
    const radii = <double>[0.0, 0.004, 0.008, 0.012, 0.016]; // ~0m, 400m..1.6km
    const dirs = <List<double>>[
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
      [1, 1],
      [-1, 1],
      [1, -1],
      [-1, -1],
    ];

    final points = <(double, double)>[(lat, lng)];
    for (final r in radii.skip(1)) {
      for (final d in dirs) {
        points.add((lat + r * d[0], lng + r * d[1]));
      }
    }

    final results = <LocationSearchResult>[];
    const batchSize = 4;
    for (var i = 0; i < points.length; i += batchSize) {
      final batch = points.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(
        batch.map((p) async {
          final reverse = await _reverseGeocode(p.$1, p.$2);
          final label = reverse?.label ?? await _formatAddress(p.$1, p.$2);
          if (label == null || label.trim().isEmpty) return null;
          return LocationSearchResult(latitude: p.$1, longitude: p.$2, label: label);
        }),
      );
      for (final r in batchResults) {
        if (r != null) results.add(r);
      }
    }

    final unique = _uniqueByLabel(results);
    unique.sort((a, b) => a.label.compareTo(b.label));
    return unique.take(25).toList();
  }

  List<LocationSearchResult> _uniqueByLabel(List<LocationSearchResult> items) {
    final seen = <String>{};
    final out = <LocationSearchResult>[];
    for (final item in items) {
      final key = item.label.trim();
      if (key.isEmpty) continue;
      if (seen.add(key)) out.add(item);
    }
    return out;
  }

  void _select(LocationSearchResult item) {
    Navigator.of(context).pop(item);
  }

  void _switchToNearbyMode() {
    _debounce?.cancel();
    if (_controller.text.isEmpty && _results.isEmpty && _error == null) return;
    setState(() {
      _controller.text = '';
      _results = const [];
      _isSearching = false;
      _error = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageLocations),
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _SearchField(
                controller: _controller,
                hintText: l10n.locationSearchHint,
                onChanged: _onQueryChanged,
                onClear: () {
                  _controller.clear();
                  _onQueryChanged('');
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingNearby ? null : _loadNearby,
                  icon: const Icon(Icons.my_location_rounded),
                  label: Text(
                    _isLoadingNearby
                        ? l10n.locationFinding
                        : l10n.locationFindByCurrentLocation,
                    style: AppTextStyles.button.copyWith(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dividerColor = colorScheme.outline.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.65 : 0.35,
    );
    final isSearchMode = _controller.text.trim().isNotEmpty;
    final data = isSearchMode ? _results : _nearby;
    final header =
        isSearchMode ? l10n.locationSearchResults : l10n.locationNearbyNeighborhoods;

    return Container(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            header,
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (_error != null)
            _ErrorBanner(message: _error!)
          else if (_isSearching)
            const Padding(
              padding: EdgeInsets.only(top: 28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Text(
                isSearchMode
                    ? l10n.locationNoSearchResults
                    : l10n.locationFailedToLoadNearby,
                style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            ...data.map(
              (item) => _LocationRow(
                label: item.label,
                onTap: () => _select(item),
                dividerColor: dividerColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _ReverseGeocodeData {
  final String label;
  final String areaKey;

  const _ReverseGeocodeData({
    required this.label,
    required this.areaKey,
  });
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: onClear,
              icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color dividerColor;

  const _LocationRow({
    required this.label,
    required this.onTap,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: dividerColor, width: 1),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.7)),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
