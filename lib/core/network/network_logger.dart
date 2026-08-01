import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final log = StringBuffer();
      log.writeln('-------------------- NETWORK REQUEST --------------------');
      log.writeln('URL: ${options.uri}');
      log.writeln('Method: ${options.method}');
      log.writeln('Headers: ${options.headers}');
      if (options.queryParameters.isNotEmpty) {
        log.writeln('Query Parameters: ${options.queryParameters}');
      }
      if (options.data != null) {
        log.writeln('Request Body: ${options.data}');
      }
      log.writeln('---------------------------------------------------------');
      developer.log(log.toString(), name: 'NetworkLogger');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final log = StringBuffer();
      log.writeln('-------------------- NETWORK RESPONSE -------------------');
      log.writeln('URL: ${response.requestOptions.uri}');
      log.writeln('Status Code: ${response.statusCode}');
      log.writeln('Response Body: ${response.data}');
      log.writeln('---------------------------------------------------------');
      developer.log(log.toString(), name: 'NetworkLogger');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final log = StringBuffer();
      log.writeln('-------------------- NETWORK ERROR ----------------------');
      log.writeln('URL: ${err.requestOptions.uri}');
      log.writeln('Method: ${err.requestOptions.method}');
      log.writeln('Status Code: ${err.response?.statusCode}');
      log.writeln('Error: ${err.message}');
      if (err.response?.data != null) {
        log.writeln('Error Data: ${err.response?.data}');
      }
      log.writeln('---------------------------------------------------------');
      developer.log(log.toString(), name: 'NetworkLogger');
    }
    super.onError(err, handler);
  }
}
