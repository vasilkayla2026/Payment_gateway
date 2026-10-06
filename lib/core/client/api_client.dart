import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// HTTP client for the backend at [AppConfig.baseUrl]; pass paths relative
/// to it.
class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: <String, dynamic>{'Accept': 'application/json'},
        ),
      ) {
    // Prints every request, response and error to the debug console.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (log) => debugPrint('$log'),
        ),
      );
    }
  }
}
