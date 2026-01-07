import 'package:flutter_test/flutter_test.dart';
import 'package:marriage_matching_app/features/location/data/google_geocoding_api.dart';
import 'package:marriage_matching_app/features/location/data/location_label_formatter.dart';

void main() {
  test('formatNeighborhoodLabelFromGoogleComponents builds ordered label', () {
    final components = [
      const GoogleAddressComponent(
        longName: 'Seoul',
        shortName: 'Seoul',
        types: ['administrative_area_level_1', 'political'],
      ),
      const GoogleAddressComponent(
        longName: 'Gwanak-gu',
        shortName: 'Gwanak-gu',
        types: ['administrative_area_level_2', 'political'],
      ),
      const GoogleAddressComponent(
        longName: 'Sillim-dong',
        shortName: 'Sillim-dong',
        types: ['sublocality_level_1', 'political'],
      ),
    ];

    expect(formatNeighborhoodLabelFromGoogleComponents(components), 'Seoul Gwanak-gu Sillim-dong');
    expect(googleAreaKeyFromComponents(components), 'Seoul|Gwanak-gu');
  });

  test('shortLocationLabel returns last two parts', () {
    expect(shortLocationLabel('Seoul Gwanak-gu Sillim-dong'), 'Gwanak-gu Sillim-dong');
    expect(shortLocationLabel('東京都 渋谷区 恵比寿'), '渋谷区 恵比寿');
    expect(shortLocationLabel('California, Los Angeles County'), 'Los Angeles County');
  });
}

