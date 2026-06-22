import 'package:dio/dio.dart';

import '../storage/app_storage.dart';
import 'api_models.dart';

const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://freitora.online/api/mobile',
);

String apiErrorMessage(Object exception) {
  if (exception is DioException) {
    final data = exception.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return '${first.first}';
        if (first != null) return '$first';
      }
      final message = data['message'];
      if (message != null && '$message'.trim().isNotEmpty) return '$message';
    }
    final statusCode = exception.response?.statusCode;
    if (statusCode == 422) return 'Please check the information and try again.';
    if (statusCode == 401) return 'Your login has expired. Please sign in again.';
    if (statusCode == 403) return 'You do not have access to this courier account.';
    if (statusCode != null && statusCode >= 500) return 'The server is having trouble. Please try again shortly.';
    if (exception.type == DioExceptionType.connectionTimeout || exception.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your internet and try again.';
    }
    if (exception.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server. Please check your internet and try again.';
    }
  }

  return exception.toString();
}
class ApiClient {
  ApiClient({required this.storage})
      : _dio = Dio(BaseOptions(
          baseUrl: defaultApiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.tokenForActiveCourier();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  final AppStorage storage;
  final Dio _dio;

  Future<CourierWorkspace> resolveCourier(String courierCode) async {
    final response = await _dio.post('/tenant/resolve', data: {
      'courier_code': courierCode.trim(),
    });

    return CourierWorkspace.fromJson(response.data['tenant'] ?? response.data);
  }

  Future<LoginResult> login({
    required int tenantId,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/login', data: {
      'tenant_id': tenantId,
      'email': email.trim(),
      'password': password,
    });

    return LoginResult.fromJson(response.data);
  }

  Future<AppBootstrap> bootstrap() async {
    final response = await _dio.get('/bootstrap');
    return AppBootstrap.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> list(String path) async {
    final response = await _dio.get(path);
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _dio.get(path);
    return (response.data as Map? ?? const {}).cast<String, dynamic>();
  }

  Future<void> post(String path, {Map<String, dynamic>? data}) async {
    await _dio.post(path, data: data);
  }

  Future<void> uploadFile(String path, {required String fieldName, required String filePath, Map<String, dynamic>? data}) async {
    final form = FormData.fromMap({
      ...?data,
      fieldName: await MultipartFile.fromFile(filePath),
    });
    await _dio.post(path, data: form);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } on DioException {
      // Local token cleanup still happens in the controller.
    }
  }
}
