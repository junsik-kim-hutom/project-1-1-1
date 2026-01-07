import 'package:dio/dio.dart';

class GoogleLatLng {
  final double lat;
  final double lng;

  const GoogleLatLng({required this.lat, required this.lng});

  factory GoogleLatLng.fromJson(Map<String, dynamic> json) {
    return GoogleLatLng(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class GoogleViewport {
  final GoogleLatLng northeast;
  final GoogleLatLng southwest;

  const GoogleViewport({required this.northeast, required this.southwest});

  factory GoogleViewport.fromJson(Map<String, dynamic> json) {
    return GoogleViewport(
      northeast: GoogleLatLng.fromJson(json['northeast'] as Map<String, dynamic>),
      southwest: GoogleLatLng.fromJson(json['southwest'] as Map<String, dynamic>),
    );
  }

  double get latSpan => (northeast.lat - southwest.lat).abs();
  double get lngSpan => (northeast.lng - southwest.lng).abs();

  GoogleLatLng get center => GoogleLatLng(
        lat: (northeast.lat + southwest.lat) / 2,
        lng: (northeast.lng + southwest.lng) / 2,
      );
}

class GoogleAddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  const GoogleAddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory GoogleAddressComponent.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['types'];
    final types = rawTypes is List ? rawTypes.map((e) => e.toString()).toList() : const <String>[];
    return GoogleAddressComponent(
      longName: json['long_name']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? '',
      types: types,
    );
  }

  bool hasType(String type) => types.contains(type);
}

class GoogleGeocodeResult {
  final GoogleLatLng location;
  final GoogleViewport? viewport;
  final String formattedAddress;
  final List<GoogleAddressComponent> components;

  const GoogleGeocodeResult({
    required this.location,
    required this.viewport,
    required this.formattedAddress,
    required this.components,
  });

  factory GoogleGeocodeResult.fromJson(Map<String, dynamic> json) {
    final geometry = (json['geometry'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final loc = (geometry['location'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final viewportJson = geometry['viewport'];
    final comps = json['address_components'];

    return GoogleGeocodeResult(
      location: GoogleLatLng.fromJson(loc),
      viewport: viewportJson is Map<String, dynamic> ? GoogleViewport.fromJson(viewportJson) : null,
      formattedAddress: json['formatted_address']?.toString() ?? '',
      components: comps is List
          ? comps
              .whereType<Map>()
              .map((e) => GoogleAddressComponent.fromJson(e.cast<String, dynamic>()))
              .toList()
          : const <GoogleAddressComponent>[],
    );
  }
}

class GoogleGeocodingApi {
  final Dio _dio;

  GoogleGeocodingApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://maps.googleapis.com/maps/api',
                connectTimeout: const Duration(seconds: 7),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  Future<List<GoogleGeocodeResult>> geocodeAddress({
    required String address,
    required String apiKey,
    String? language,
    String? region,
    int limit = 10,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/geocode/json',
      queryParameters: {
        'address': address,
        if (language != null && language.isNotEmpty) 'language': language,
        if (region != null && region.isNotEmpty) 'region': region,
        'key': apiKey,
      },
      options: Options(responseType: ResponseType.json),
    );

    return _parseResults(resp.data, limit: limit);
  }

  Future<List<GoogleGeocodeResult>> reverseGeocode({
    required double latitude,
    required double longitude,
    required String apiKey,
    String? language,
    String? region,
    int limit = 5,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/geocode/json',
      queryParameters: {
        'latlng': '$latitude,$longitude',
        if (language != null && language.isNotEmpty) 'language': language,
        if (region != null && region.isNotEmpty) 'region': region,
        'key': apiKey,
      },
      options: Options(responseType: ResponseType.json),
    );

    return _parseResults(resp.data, limit: limit);
  }

  Future<GoogleViewport?> geocodeViewport({
    required String address,
    required String apiKey,
    String? language,
    String? region,
  }) async {
    final results = await geocodeAddress(
      address: address,
      apiKey: apiKey,
      language: language,
      region: region,
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first.viewport;
  }

  List<GoogleGeocodeResult> _parseResults(Map<String, dynamic>? data, {required int limit}) {
    if (data == null) return const [];
    final status = data['status']?.toString();
    if (status != 'OK') return const [];

    final results = data['results'];
    if (results is! List) return const [];
    final parsed = results
        .whereType<Map>()
        .map((e) => GoogleGeocodeResult.fromJson(e.cast<String, dynamic>()))
        .toList();

    if (limit <= 0) return parsed;
    return parsed.take(limit).toList();
  }
}
