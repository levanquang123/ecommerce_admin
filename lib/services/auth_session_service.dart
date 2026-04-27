import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/routes/app_pages.dart';
import '../models/auth_session.dart';
import '../models/user.dart';
import '../utility/constants.dart';

class AuthSessionService {
  AuthSessionService._();

  static final AuthSessionService instance = AuthSessionService._();

  final GetStorage _box = GetStorage();
  final Uuid _uuid = const Uuid();
  Completer<bool>? _refreshCompleter;
  bool _isNavigatingToLogin = false;

  String? get accessToken => _box.read(TOKEN)?.toString();
  String? get refreshToken => _box.read(REFRESH_TOKEN)?.toString();

  User? get currentUser {
    final rawUser = _box.read(USER_KEY);
    if (rawUser is Map<String, dynamic>) {
      return User.fromJson(rawUser);
    }
    if (rawUser is Map) {
      return User.fromJson(rawUser.cast<String, dynamic>());
    }
    return null;
  }

  bool get hasAdminRole {
    final role = currentUser?.role;
    return role == 'admin' || role == 'superadmin';
  }

  DateTime? _readJwtExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded);
      if (payloadMap is! Map<String, dynamic>) {
        return null;
      }

      final exp = payloadMap['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      if (exp is String) {
        final parsed = int.tryParse(exp);
        if (parsed != null) {
          return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isJwtExpired(String token,
      {Duration skew = const Duration(seconds: 15)}) {
    final expiresAt = _readJwtExpiry(token);
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().add(skew).isAfter(expiresAt);
  }

  Future<void> _setSentryUserContext(User? user) async {
    await Sentry.configureScope((scope) async {
      if (user == null) {
        await scope.setUser(null);
        return;
      }

      await scope.setUser(
        SentryUser(
          id: user.sId,
          data: {'role': user.role ?? 'unknown'},
        ),
      );
    });
  }

  Map<String, String> _buildRequestHeaders({
    required Map<String, String> baseHeaders,
    bool includeAuthToken = false,
  }) {
    final headers = <String, String>{
      ...baseHeaders,
      'x-client-type': 'web_admin',
      'x-request-id': _uuid.v4(),
    };

    if (includeAuthToken) {
      final token = accessToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final span = Sentry.getSpan();
    final traceHeader = span?.toSentryTrace();
    final baggageHeader = span?.toBaggageHeader();

    if (traceHeader != null) {
      headers[traceHeader.name] = traceHeader.value;
    }

    if (baggageHeader != null && baggageHeader.value.isNotEmpty) {
      headers[baggageHeader.name] = baggageHeader.value;
    }

    return headers;
  }

  Future<void> _captureAuthHttpFailure({
    required String endpoint,
    required String method,
    required Map<String, String> requestHeaders,
    required Response<dynamic> response,
  }) async {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 400) {
      return;
    }

    await Sentry.captureException(
      Exception('Auth request failed: $method $endpoint -> $statusCode'),
      withScope: (scope) {
        scope.setTag('service', 'admin-web');
        scope.setTag('client_type', 'web_admin');
        scope.setTag('endpoint', endpoint);
        scope.setTag('method', method);
        scope.setTag('status_code', statusCode.toString());

        final requestId = requestHeaders['x-request-id'];
        if (requestId != null && requestId.isNotEmpty) {
          scope.setTag('request_id', requestId);
        }

        scope.setContexts('http', {
          'url': '$MAIN_URL$endpoint',
          'method': method,
          'request_id': requestId,
          'status_code': statusCode,
        });
      },
    );
  }

  Future<void> saveSession(AuthSession session) async {
    if (session.hasAccessToken) {
      await _box.write(TOKEN, session.accessToken);
    }

    if (session.hasRefreshToken) {
      await _box.write(REFRESH_TOKEN, session.refreshToken);
    }

    if (session.tokenType != null) {
      await _box.write(TOKEN_TYPE, session.tokenType);
    }

    if (session.accessTokenExpiresIn != null) {
      await _box.write(ACCESS_TOKEN_EXPIRES_IN, session.accessTokenExpiresIn);
    }

    if (session.user != null) {
      await _box.write(USER_KEY, session.user!.toJson());
    }

    await _setSentryUserContext(session.user ?? currentUser);
  }

  Future<void> clearSession() async {
    await _box.remove(TOKEN);
    await _box.remove(REFRESH_TOKEN);
    await _box.remove(TOKEN_TYPE);
    await _box.remove(ACCESS_TOKEN_EXPIRES_IN);
    await _box.remove(USER_KEY);
    await _setSentryUserContext(null);
  }

  Future<void> clearSessionAndRedirectToLogin() async {
    await clearSession();

    if (_isNavigatingToLogin) {
      return;
    }

    _isNavigatingToLogin = true;
    try {
      if (Get.currentRoute != AppPages.LOGIN) {
        Get.offAllNamed(AppPages.LOGIN);
      }
    } catch (_) {
      // Ignore navigation issues before Get tree is ready.
    } finally {
      _isNavigatingToLogin = false;
    }
  }

  Future<Response<dynamic>> _postWithoutAuthHeader(
      String endpoint, dynamic body) async {
    final client = GetConnect()
      ..baseUrl = MAIN_URL
      ..timeout = const Duration(seconds: 30);

    final transaction = Sentry.startTransaction(
      'POST $endpoint',
      'http.client',
      bindToScope: true,
    );
    transaction.setTag('service', 'admin-web');
    transaction.setTag('endpoint', endpoint);
    transaction.setTag('method', 'POST');

    try {
      final headers = _buildRequestHeaders(
          baseHeaders: const {'Content-Type': 'application/json'});

      final response = await client.post(
        endpoint,
        body,
        headers: headers,
      );

      await _captureAuthHttpFailure(
        endpoint: endpoint,
        method: 'POST',
        requestHeaders: headers,
        response: response,
      );
      transaction.status = (response.statusCode ?? 0) >= 400
          ? const SpanStatus.internalError()
          : const SpanStatus.ok();
      return response;
    } catch (error, stackTrace) {
      transaction.status = const SpanStatus.internalError();
      transaction.throwable = error;
      await Sentry.captureException(error, stackTrace: stackTrace);
      rethrow;
    } finally {
      await transaction.finish();
    }
  }

  Future<bool> refreshSession() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final currentRefreshToken = refreshToken;
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      await clearSessionAndRedirectToLogin();
      return false;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final response = await _postWithoutAuthHeader(
        'users/refresh-token',
        {'refreshToken': currentRefreshToken},
      );

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true &&
          response.body['data'] != null) {
        final data = response.body['data'];
        if (data is Map<String, dynamic>) {
          final session = AuthSession.fromJson(data);

          final roleFromResponse = session.user?.role ?? currentUser?.role;
          final isRoleValid =
              roleFromResponse == 'admin' || roleFromResponse == 'superadmin';

          if (session.hasAccessToken &&
              session.hasRefreshToken &&
              isRoleValid) {
            await saveSession(session);
            completer.complete(true);
            return true;
          }
        }
      }

      await clearSessionAndRedirectToLogin();
      completer.complete(false);
      return false;
    } catch (error) {
      log('[AUTH] Refresh failed: $error');
      await clearSessionAndRedirectToLogin();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<bool> bootstrapSession() async {
    final currentAccessToken = accessToken;
    final currentRefreshToken = refreshToken;
    final user = currentUser;

    if (currentRefreshToken == null ||
        currentRefreshToken.isEmpty ||
        user == null ||
        !hasAdminRole) {
      await clearSession();
      return false;
    }

    if (_isJwtExpired(currentRefreshToken)) {
      await clearSessionAndRedirectToLogin();
      return false;
    }

    if (currentAccessToken != null &&
        currentAccessToken.isNotEmpty &&
        !_isJwtExpired(currentAccessToken)) {
      await _setSentryUserContext(user);
      return true;
    }

    return refreshSession();
  }

  Future<void> logout() async {
    final token = accessToken;

    if (token != null && token.isNotEmpty) {
      try {
        final client = GetConnect()
          ..baseUrl = MAIN_URL
          ..timeout = const Duration(seconds: 30);
        final transaction = Sentry.startTransaction(
          'POST users/logout',
          'http.client',
          bindToScope: true,
        );
        transaction.setTag('service', 'admin-web');
        transaction.setTag('endpoint', 'users/logout');
        transaction.setTag('method', 'POST');
        try {
          final headers = _buildRequestHeaders(
            baseHeaders: const {},
            includeAuthToken: true,
          );
          final response = await client.post(
            'users/logout',
            {},
            headers: headers,
          );
          await _captureAuthHttpFailure(
            endpoint: 'users/logout',
            method: 'POST',
            requestHeaders: headers,
            response: response,
          );
          transaction.status = (response.statusCode ?? 0) >= 400
              ? const SpanStatus.internalError()
              : const SpanStatus.ok();
        } catch (error) {
          transaction.status = const SpanStatus.internalError();
          transaction.throwable = error;
          rethrow;
        } finally {
          await transaction.finish();
        }
      } catch (error) {
        log('[AUTH] Logout API failed: $error');
        await Sentry.captureException(
          error,
          withScope: (scope) {
            scope.setTag('service', 'admin-web');
            scope.setTag('client_type', 'web_admin');
            scope.setTag('endpoint', 'users/logout');
            scope.setTag('method', 'POST');
          },
        );
      }
    }

    await clearSessionAndRedirectToLogin();
  }
}
