import 'package:flutter_test/flutter_test.dart';
import 'package:marriage_matching_app/features/location/data/google_geocoding_api.dart';

void main() {
  test('GoogleViewport parses and computes spans/center', () {
    final viewport = GoogleViewport.fromJson({
      'northeast': {'lat': 37.5, 'lng': 127.1},
      'southwest': {'lat': 37.3, 'lng': 126.9},
    });

    expect(viewport.latSpan, closeTo(0.2, 1e-9));
    expect(viewport.lngSpan, closeTo(0.2, 1e-9));
    expect(viewport.center.lat, closeTo(37.4, 1e-9));
    expect(viewport.center.lng, closeTo(127.0, 1e-9));
  });
}

