import 'dart:ui';

String? googleRegionForLocale(Locale locale) {
  final cc = (locale.countryCode ?? '').trim().toLowerCase();
  if (cc.isEmpty) return null;
  // Google Geocoding `region` expects a ccTLD-style 2-letter code.
  // Only pass for countries we explicitly support to avoid surprising behavior.
  if (cc == 'kr' || cc == 'jp' || cc == 'us') return cc;
  return null;
}

bool looksLikeAdministrativeQuery(String query, Locale locale) {
  final q = query.trim();
  if (q.isEmpty) return false;

  final compact = q.replaceAll(RegExp(r'\s+'), '');
  final cc = (locale.countryCode ?? '').trim().toUpperCase();
  final lang = locale.languageCode.toLowerCase();

  bool endsWithAny(List<String> suffixes) => suffixes.any(compact.endsWith);

  // Korea
  if (cc == 'KR' || lang == 'ko') {
    return endsWithAny(['구', '군', '시', '읍', '면']);
  }

  // Japan
  if (cc == 'JP' || lang == 'ja') {
    // Common administrative suffixes.
    return endsWithAny(['都', '道', '府', '県', '市', '区', '町', '村', '郡']);
  }

  // USA (English keywords)
  if (cc == 'US' || lang == 'en') {
    final lower = q.toLowerCase();
    // Use word boundary-ish checks to avoid matching inside other words.
    return RegExp(r'(\bcounty\b|\bcity\b|\btown\b|\bvillage\b|\bborough\b|\bparish\b|\bstate\b|\bprovince\b)')
        .hasMatch(lower);
  }

  return false;
}

String _normalizeForMatch(String input, {required Locale locale}) {
  var s = input.toLowerCase();
  // Remove common separators and whitespace.
  s = s.replaceAll(RegExp(r'[\s,./\-()]+'), '');
  // Normalize Japanese middle dot, etc.
  s = s.replaceAll('・', '');
  return s;
}

bool labelMatchesQuery(String label, String query, Locale locale) {
  final q = query.trim();
  final l = label.trim();
  if (q.isEmpty || l.isEmpty) return false;

  final normQ = _normalizeForMatch(q, locale: locale);
  final normL = _normalizeForMatch(l, locale: locale);
  if (normQ.isEmpty || normL.isEmpty) return false;

  return normL.contains(normQ);
}

