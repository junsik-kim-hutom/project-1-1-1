import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
          print('[API_CLIENT] Request to: ${options.path}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('[API_CLIENT] Added Authorization header');
          } else {
            print('[API_CLIENT] No access token found');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          print('[API_CLIENT] Error occurred: ${error.response?.statusCode}');
          print('[API_CLIENT] Error path: ${error.requestOptions.path}');
          print('[API_CLIENT] Error response: ${error.response?.data}');

          if (error.response?.statusCode == 401) {
            final shouldSkipRefresh =
                error.requestOptions.path == ApiConstants.authRefresh ||
                    error.requestOptions.extra['skipAuthRefresh'] == true;

            print('[API_CLIENT] Should skip refresh: $shouldSkipRefresh');
            print('[API_CLIENT] Is refreshing: ${_refreshCompleter != null}');

            if (!shouldSkipRefresh) {
              final alreadyRetried =
                  error.requestOptions.extra['retriedAfterRefresh'] == true;
              if (alreadyRetried) {
                return handler.next(error);
              }

              final refreshed = await _refreshOrWait();
              print('[API_CLIENT] Token refresh result: $refreshed');

              if (refreshed) {
                print('[API_CLIENT] Retrying original request after refresh...');
                final retryOptions = error.requestOptions;
                retryOptions.extra['retriedAfterRefresh'] = true;
                return handler.resolve(await _retry(retryOptions));
              }

              print('[API_CLIENT] Token refresh failed, clearing tokens');
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
      print('[API_CLIENT] _refreshToken: Reading refresh token from storage');
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (refreshToken == null) {
        print('[API_CLIENT] _refreshToken: No refresh token found');
        return false;
      }

      print('[API_CLIENT] _refreshToken: Sending refresh request to ${ApiConstants.authRefresh}');
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: {'skipAuthRefresh': true},
        ),
      );

      print('[API_CLIENT] _refreshToken: Response status: ${response.statusCode}');
      print('[API_CLIENT] _refreshToken: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        print('[API_CLIENT] _refreshToken: Got new access token');
        await _storage.write(key: 'access_token', value: newAccessToken);
        print('[API_CLIENT] _refreshToken: Saved new access token');
        return true;
      }
      print('[API_CLIENT] _refreshToken: Unexpected status code: ${response.statusCode}');
      return false;
    } catch (e) {
      print('[API_CLIENT] _refreshToken: Exception occurred: $e');
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
      print('[API_CLIENT] Attempting to refresh token...');
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

  Dio get dio => _dio;
}
