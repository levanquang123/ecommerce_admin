import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utility/constants.dart';
import 'auth_session_service.dart';

class HttpService extends GetConnect {
  final GetStorage _box = GetStorage();
  final AuthSessionService _authSessionService = AuthSessionService.instance;
  final Uuid _uuid = const Uuid();

  HttpService() {
    baseUrl = MAIN_URL;
    timeout = const Duration(seconds: 30);
    httpClient.baseUrl = MAIN_URL;

    httpClient.addRequestModifier<dynamic>((request) async {
      final token = _box.read(TOKEN)?.toString();
      final requestPath = request.url.path;
      request.headers['x-client-type'] = 'web_admin';
      request.headers['x-request-id'] = _uuid.v4();

      final span = Sentry.getSpan();
      final traceHeader = span?.toSentryTrace();
      final baggageHeader = span?.toBaggageHeader();

      if (traceHeader != null) {
        request.headers[traceHeader.name] = traceHeader.value;
      }

      if (baggageHeader != null && baggageHeader.value.isNotEmpty) {
        request.headers[baggageHeader.name] = baggageHeader.value;
      }

      if (token != null &&
          token.isNotEmpty &&
          !_isRefreshTokenEndpoint(requestPath)) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      log('--- [HTTP REQUEST] ---');
      log('URL: ${request.url}');
      log('Method: ${request.method}');
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      log('--- [HTTP RESPONSE] ---');
      log('URL: ${request.url}');
      log('Status Code: ${response.statusCode}');
      if ((response.statusCode ?? 0) >= 400) {
        _captureHttpFailure(request: request, response: response);
      }
      if (response.statusCode == 401) {
        log('[AUTH] Unauthorized response');
      }
      return response;
    });
  }

  bool _isRefreshTokenEndpoint(String endpointUrl) {
    return endpointUrl.contains('users/refresh-token');
  }

  bool _isAuthFreeEndpoint(String endpointUrl) {
    return endpointUrl.contains('users/login') ||
        endpointUrl.contains('users/register') ||
        endpointUrl.contains('users/refresh-token');
  }

  bool _shouldTryRefresh(String endpointUrl) {
    return !_isAuthFreeEndpoint(endpointUrl);
  }

  Map<String, dynamic> _summarizeResponseBody(dynamic body) {
    if (body == null) {
      return {'type': 'null'};
    }
    if (body is Map) {
      return {
        'type': 'map',
        'keys': body.keys.take(10).map((key) => key.toString()).toList(),
      };
    }
    if (body is List) {
      return {'type': 'list', 'length': body.length};
    }
    if (body is String) {
      return {'type': 'string', 'length': body.length};
    }
    return {'type': body.runtimeType.toString()};
  }

  Future<void> _captureHttpFailure({
    required dynamic request,
    required Response<dynamic> response,
  }) async {
    final statusCode = response.statusCode ?? 0;
    final requestId = request.headers['x-request-id'];

    await Sentry.captureException(
      Exception(
        'API request failed: ${request.method.toUpperCase()} ${request.url.path} -> $statusCode',
      ),
      withScope: (scope) {
        scope.setTag('service', 'admin-web');
        scope.setTag('client_type', 'web_admin');
        scope.setTag('endpoint', request.url.path);
        scope.setTag('method', request.method.toUpperCase());
        scope.setTag('status_code', statusCode.toString());
        if (requestId != null && requestId.isNotEmpty) {
          scope.setTag('request_id', requestId);
        }

        scope.setContexts('http', {
          'url': request.url.toString(),
          'method': request.method.toUpperCase(),
          'request_id': requestId,
          'status_code': statusCode,
          'response': _summarizeResponseBody(response.body),
        });
      },
    );
  }

  SpanStatus _spanStatusFromCode(int? statusCode) {
    final code = statusCode ?? 0;
    if (code >= 500) {
      return const SpanStatus.internalError();
    }
    if (code >= 400) {
      return const SpanStatus.invalidArgument();
    }
    if (code >= 300) {
      return const SpanStatus.ok();
    }
    return const SpanStatus.ok();
  }

  Future<Response<dynamic>> _traceRequestAttempt({
    required String endpointUrl,
    required String method,
    required Future<Response<dynamic>> Function() requestCall,
  }) async {
    final transaction = Sentry.startTransaction(
      '$method $endpointUrl',
      'http.client',
      bindToScope: true,
    );
    transaction.setTag('service', 'admin-web');
    transaction.setTag('endpoint', endpointUrl);
    transaction.setTag('method', method);

    try {
      final response = await requestCall();
      transaction.status = _spanStatusFromCode(response.statusCode);
      return response;
    } catch (error, stackTrace) {
      transaction.status = const SpanStatus.internalError();
      transaction.throwable = error;
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('service', 'admin-web');
          scope.setTag('client_type', 'web_admin');
          scope.setTag('endpoint', endpointUrl);
          scope.setTag('method', method);
        },
      );
      rethrow;
    } finally {
      await transaction.finish();
    }
  }

  Future<Response<dynamic>> _executeWithAuthRetry({
    required String endpointUrl,
    required String method,
    required Future<Response<dynamic>> Function() requestCall,
  }) async {
    Response<dynamic> response = await _traceRequestAttempt(
      endpointUrl: endpointUrl,
      method: method,
      requestCall: requestCall,
    );

    if (response.statusCode == 401 && _shouldTryRefresh(endpointUrl)) {
      final refreshed = await _authSessionService.refreshSession();
      if (refreshed) {
        response = await _traceRequestAttempt(
          endpointUrl: endpointUrl,
          method: method,
          requestCall: requestCall,
        );
      } else {
        return response;
      }
    }

    if (response.statusCode == 401) {
      await _authSessionService.clearSessionAndRedirectToLogin();
    }

    return response;
  }

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      return await _executeWithAuthRetry(
        endpointUrl: endpointUrl,
        method: 'GET',
        requestCall: () => get(endpointUrl),
      );
    } catch (e, stackTrace) {
      log('[GET ERROR] $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('service', 'admin-web');
          scope.setTag('client_type', 'web_admin');
          scope.setTag('endpoint', endpointUrl);
          scope.setTag('method', 'GET');
        },
      );
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> addItem({
    required String endpointUrl,
    required dynamic itemData,
  }) async {
    try {
      return await _executeWithAuthRetry(
        endpointUrl: endpointUrl,
        method: 'POST',
        requestCall: () => post(endpointUrl, itemData),
      );
    } catch (e, stackTrace) {
      log('[POST ERROR] $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('service', 'admin-web');
          scope.setTag('client_type', 'web_admin');
          scope.setTag('endpoint', endpointUrl);
          scope.setTag('method', 'POST');
        },
      );
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> updateItem({
    required String endpointUrl,
    required String itemId,
    required dynamic itemData,
  }) async {
    try {
      final path = '$endpointUrl/$itemId';
      return await _executeWithAuthRetry(
        endpointUrl: path,
        method: 'PUT',
        requestCall: () => put(path, itemData),
      );
    } catch (e, stackTrace) {
      log('[PUT ERROR] $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('service', 'admin-web');
          scope.setTag('client_type', 'web_admin');
          scope.setTag('endpoint', '$endpointUrl/$itemId');
          scope.setTag('method', 'PUT');
        },
      );
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  }) async {
    try {
      final path = '$endpointUrl/$itemId';
      return await _executeWithAuthRetry(
        endpointUrl: path,
        method: 'DELETE',
        requestCall: () => delete(path),
      );
    } catch (e, stackTrace) {
      log('[DELETE ERROR] $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('service', 'admin-web');
          scope.setTag('client_type', 'web_admin');
          scope.setTag('endpoint', '$endpointUrl/$itemId');
          scope.setTag('method', 'DELETE');
        },
      );
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }
}
