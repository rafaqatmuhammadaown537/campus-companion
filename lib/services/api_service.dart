import 'package:dio/dio.dart';

import 'demo_backend.dart';

/// Thin REST client around Dio. Every request carries the JWT in the
/// Authorization header once a session is established.
///
/// [baseUrl] points at the campus REST API. When the backend is unreachable
/// (the app ships with a demo backend, no real server), [DemoBackendInterceptor]
/// answers the same routes with realistic JSON so the app stays fully usable
/// offline-first.
class ApiService {
  ApiService({this.baseUrl = DemoBackend.baseUrl, String? token}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(DemoBackendInterceptor());
    if (token != null) applyToken(token);
  }

  late final Dio _dio;
  final String baseUrl;

  void applyToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
    return res.data;
  }

  Future<dynamic> post(String path, {Object? data}) async {
    final res = await _dio.post<Map<String, dynamic>>(path, data: data);
    return res.data;
  }
}
