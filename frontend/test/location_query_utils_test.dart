import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:marriage_matching_app/features/location/data/location_query_utils.dart';

void main() {
  group('googleRegionForLocale', () {
    test('returns supported cc', () {
      expect(googleRegionForLocale(const Locale('ko', 'KR')), 'kr');
      expect(googleRegionForLocale(const Locale('ja', 'JP')), 'jp');
      expect(googleRegionForLocale(const Locale('en', 'US')), 'us');
    });

    test('returns null for unsupported cc', () {
      expect(googleRegionForLocale(const Locale('en', 'GB')), null);
      expect(googleRegionForLocale(const Locale('en')), null);
    });
  });

  group('looksLikeAdministrativeQuery', () {
    test('Korea suffix triggers', () {
      const locale = Locale('ko', 'KR');
      expect(looksLikeAdministrativeQuery('관악구', locale), true);
      expect(looksLikeAdministrativeQuery('서울시', locale), true);
      expect(looksLikeAdministrativeQuery('강남', locale), false);
    });

    test('Japan suffix triggers', () {
      const locale = Locale('ja', 'JP');
      expect(looksLikeAdministrativeQuery('渋谷区', locale), true);
      expect(looksLikeAdministrativeQuery('横浜市', locale), true);
      expect(looksLikeAdministrativeQuery('東京', locale), false);
    });

    test('US keyword triggers', () {
      const locale = Locale('en', 'US');
      expect(looksLikeAdministrativeQuery('Los Angeles County', locale), true);
      expect(looksLikeAdministrativeQuery('New York City', locale), true);
      expect(looksLikeAdministrativeQuery('Los Angeles', locale), false);
    });
  });

  group('labelMatchesQuery', () {
    test('matches ignoring spaces/commas/case', () {
      const locale = Locale('en', 'US');
      expect(
          labelMatchesQuery(
              'California, Los Angeles County', 'los angeles county', locale),
          true);
      expect(
          labelMatchesQuery(
              'California LosAngelesCounty', 'Los Angeles County', locale),
          true);
    });

    test('matches Japanese without separators', () {
      const locale = Locale('ja', 'JP');
      expect(labelMatchesQuery('東京都 渋谷区 恵比寿', '渋谷区', locale), true);
    });
  });
}
