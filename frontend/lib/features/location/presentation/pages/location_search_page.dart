import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';

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
  final _controller = TextEditingController();
  Timer? _debounce;

  bool _isSearching = false;
  bool _isLoadingNearby = false;

  List<LocationSearchResult> _nearby = const [];
  List<LocationSearchResult> _results = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearby();
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
        final locations = await locationFromAddress(query);
        final limited = locations.take(10).toList();
        final results = <LocationSearchResult>[];
        for (final loc in limited) {
          final label = await _formatAddress(loc.latitude, loc.longitude) ?? query;
          results.add(
            LocationSearchResult(
              latitude: loc.latitude,
              longitude: loc.longitude,
              label: label,
            ),
          );
        }
        if (!mounted) return;
        setState(() {
          _results = _uniqueByLabel(results);
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = '${AppLocalizations.of(context)!.locationSearchFailed} $e';
          _results = const [];
        });
      } finally {
        if (!mounted) return;
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  Future<String?> _formatAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String>[
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
        if ((p.subAdministrativeArea ?? '').isNotEmpty) p.subAdministrativeArea!,
        if ((p.locality ?? '').isNotEmpty) p.locality!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
      ];
      if (parts.isEmpty) return null;
      return parts.join(' ');
    } catch (_) {
      return null;
    }
  }

  Future<List<LocationSearchResult>> _reverseGeocodeCluster(double lat, double lng) async {
    // Sample nearby points to emulate "근처 동네" list without a dedicated POI API.
    const offsets = <List<double>>[
      [0.0, 0.0],
      [0.006, 0.0],
      [-0.006, 0.0],
      [0.0, 0.006],
      [0.0, -0.006],
      [0.008, 0.004],
      [-0.008, -0.004],
    ];

    final results = <LocationSearchResult>[];
    for (final o in offsets) {
      final lat2 = lat + o[0];
      final lng2 = lng + o[1];
      final label = await _formatAddress(lat2, lng2);
      if (label == null || label.trim().isEmpty) continue;
      results.add(
        LocationSearchResult(latitude: lat2, longitude: lng2, label: label),
      );
    }

    return _uniqueByLabel(results);
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
