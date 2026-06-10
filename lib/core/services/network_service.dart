import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

/// Simplified network service for basic HTTP operations
class NetworkService {
  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  // Network timeouts
  static const Duration _connectTimeout = Duration(seconds: 30);

  NetworkService();

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      _logger.error('Error checking connectivity', e);
      return false;
    }
  }

  /// Make GET request
  Future<T> get<T>(
    String url, {
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
  }) async {
    return await _errorHandler.handleAsyncError('GET $url', () async {
      if (!await isConnected()) {
        throw const NetworkException('No internet connection');
      }

      final client = HttpClient();
      client.connectionTimeout = _connectTimeout;

      try {
        final request = await client.getUrl(Uri.parse(url));

        if (headers != null) {
          headers.forEach((key, value) {
            request.headers.add(key, value);
          });
        }

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(responseBody);
          return parser != null ? parser(data) : data as T;
        } else {
          throw NetworkException('HTTP ${response.statusCode}: $responseBody');
        }
      } finally {
        client.close();
      }
    });
  }

  /// Make POST request
  Future<T> post<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
  }) async {
    return await _errorHandler.handleAsyncError('POST $url', () async {
      if (!await isConnected()) {
        throw const NetworkException('No internet connection');
      }

      final client = HttpClient();
      client.connectionTimeout = _connectTimeout;

      try {
        final request = await client.postUrl(Uri.parse(url));

        // Set default headers
        request.headers.add('Content-Type', 'application/json');

        if (headers != null) {
          headers.forEach((key, value) {
            request.headers.add(key, value);
          });
        }

        // Add body if provided
        if (data != null) {
          final jsonData = json.encode(data);
          request.add(utf8.encode(jsonData));
        }

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = json.decode(responseBody);
          return parser != null ? parser(responseData) : responseData as T;
        } else {
          throw NetworkException('HTTP ${response.statusCode}: $responseBody');
        }
      } finally {
        client.close();
      }
    });
  }

  /// Download file
  Future<void> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    await _errorHandler.handleAsyncError('Download file', () async {
      if (!await isConnected()) {
        throw const NetworkException('No internet connection');
      }

      final client = HttpClient();
      client.connectionTimeout = _connectTimeout;

      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final file = File(savePath);
          final sink = file.openWrite();

          int received = 0;
          final total = response.contentLength;

          await for (final chunk in response) {
            received += chunk.length;
            sink.add(chunk);

            if (onProgress != null && total > 0) {
              onProgress(received, total);
            }
          }

          await sink.close();
        } else {
          throw NetworkException('HTTP ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    });
  }
}

/// Custom network exception
class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
