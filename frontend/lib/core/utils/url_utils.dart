import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

String? resolveNetworkUrl(String? url) {
  final raw = url?.trim();
  if (raw == null || raw.isEmpty) return null;

  final base = Uri.tryParse(ApiConstants.baseUrl);

  // Relative path from backend: "/uploads/..."
  if (raw.startsWith('/')) {
    if (base == null) return raw;
    return base.replace(path: raw, query: null, fragment: null).toString();
  }

  final uri = Uri.tryParse(raw);
  if (uri == null) return raw;
  if (!uri.hasScheme) return raw;

  // In Android emulator/device, "localhost" points to the device itself.
  // Use the app's API baseUrl host instead.
  if ((uri.host == 'localhost' || uri.host == '127.0.0.1') &&
      base != null &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android) {
    return uri
        .replace(
          scheme: base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : uri.port,
        )
        .toString();
  }

  return raw;
}

