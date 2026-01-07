import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'dart:async';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  Completer<bool>? _refreshCompleter;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          _log('Request to: ${options.path}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            _log('Added Authorization header');
          } else {
            _log('No access token found');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          _log('Error occurred: ${error.response?.statusCode}');
          _log('Error path: ${error.requestOptions.path}');
          _log('Error response: ${error.response?.data}');

          if (error.response?.statusCode == 401) {
            final shouldSkipRefresh =
                error.requestOptions.path == ApiConstants.authRefresh ||
                    error.requestOptions.extra['skipAuthRefresh'] == true;

            _log('Should skip refresh: $shouldSkipRefresh');
            _log('Is refreshing: ${_refreshCompleter != null}');

            if (!shouldSkipRefresh) {
              final alreadyRetried =
                  error.requestOptions.extra['retriedAfterRefresh'] == true;
              if (alreadyRetried) {
                return handler.next(error);
              }

              final refreshed = await _refreshOrWait();
              _log('Token refresh result: $refreshed');

              if (refreshed) {
                _log('Retrying original request after refresh...');
                final retryOptions = error.requestOptions;
                retryOptions.extra['retriedAfterRefresh'] = true;
                return handler.resolve(await _retry(retryOptions));
              }

              _log('Token refresh failed, clearing tokens');
              await _storage.deleteAll();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      _log('_refreshToken: Reading refresh token from storage');
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (refreshToken == null) {
        _log('_refreshToken: No refresh token found');
        return false;
      }

      _log(
          '_refreshToken: Sending refresh request to ${ApiConstants.authRefresh}');
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: {'skipAuthRefresh': true},
        ),
      );

      _log('_refreshToken: Response status: ${response.statusCode}');
      _log('_refreshToken: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        _log('_refreshToken: Got new access token');
        await _storage.write(key: 'access_token', value: newAccessToken);
        _log('_refreshToken: Saved new access token');
        return true;
      }
      _log('_refreshToken: Unexpected status code: ${response.statusCode}');
      return false;
    } catch (e) {
      _log('_refreshToken: Exception occurred: $e');
      return false;
    }
  }

  Future<bool> _refreshOrWait() async {
    final existing = _refreshCompleter;
    if (existing != null) {
      return existing.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;
    try {
      _log('Attempting to refresh token...');
      final refreshed = await _refreshToken();
      completer.complete(refreshed);
      return refreshed;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[API_CLIENT] $message');
    }
  }

  Dio get dio => _dio;
}
