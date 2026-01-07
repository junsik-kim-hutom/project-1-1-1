import 'package:geocoding/geocoding.dart';

import 'google_geocoding_api.dart';

String? formatNeighborhoodLabelFromPlacemark(Placemark placemark) {
  final parts = <String>[];

  void addPart(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return;
    if (parts.contains(v)) return;
    parts.add(v);
  }

  addPart(placemark.administrativeArea);
  addPart(placemark.subAdministrativeArea);
  addPart(placemark.locality);
  addPart(placemark.subLocality);

  if (parts.isEmpty) return null;
  return parts.join(' ');
}

String? _componentLongName(List<GoogleAddressComponent> components, String type) {
  for (final c in components) {
    if (c.hasType(type)) {
      final v = c.longName.trim();
      if (v.isNotEmpty) return v;
    }
  }
  return null;
}

String googleAreaKeyFromComponents(List<GoogleAddressComponent> components) {
  final admin1 = _componentLongName(components, 'administrative_area_level_1') ?? '';
  final admin2 = _componentLongName(components, 'administrative_area_level_2') ?? '';
  return '$admin1|$admin2';
}

String? formatNeighborhoodLabelFromGoogleComponents(List<GoogleAddressComponent> components) {
  // Prefer these levels; many countries map well to this set.
  final admin1 = _componentLongName(components, 'administrative_area_level_1');
  final admin2 = _componentLongName(components, 'administrative_area_level_2');
  final locality = _componentLongName(components, 'locality');

  // sublocality levels are used for "동/町/Neighborhood" style names.
  final sublocality2 = _componentLongName(components, 'sublocality_level_2');
  final sublocality1 = _componentLongName(components, 'sublocality_level_1');
  final neighborhood = _componentLongName(components, 'neighborhood');

  final parts = <String>[];
  void add(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return;
    if (parts.contains(s)) return;
    parts.add(s);
  }

  add(admin1);
  add(admin2);
  add(locality);
  add(sublocality1);
  add(sublocality2);
  add(neighborhood);

  if (parts.isEmpty) return null;
  return parts.join(' ');
}

String shortLocationLabel(String address, {int maxParts = 2}) {
  final normalized = address.trim();
  if (normalized.isEmpty) return address;
  final tokens = normalized
      .split(RegExp(r'[\s,]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return normalized;
  if (tokens.length <= maxParts) return tokens.join(' ');

  final last = tokens.last.toLowerCase();
  const englishAdminTail = {
    'county',
    'city',
    'town',
    'village',
    'borough',
    'parish',
    'state',
    'province',
  };
  if (englishAdminTail.contains(last) && tokens.length >= 3) {
    // Preserve multi-word names like "Los Angeles County", "New York City".
    return tokens.sublist(tokens.length - 3).join(' ');
  }

  return tokens.sublist(tokens.length - maxParts).join(' ');
}
