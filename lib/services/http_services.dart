import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../utility/constants.dart';
import 'auth_session_service.dart';

class HttpService extends GetConnect {
  final GetStorage _box = GetStorage();
  final AuthSessionService _authSessionService = AuthSessionService.instance;

  HttpService() {
    baseUrl = MAIN_URL;
    timeout = const Duration(seconds: 30);
    httpClient.baseUrl = MAIN_URL;

    httpClient.addRequestModifier<dynamic>((request) {
      final token = _box.read(TOKEN)?.toString();
      final requestPath = request.url.path;

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

  Future<Response<dynamic>> _executeWithAuthRetry({
    required String endpointUrl,
    required Future<Response<dynamic>> Function() requestCall,
  }) async {
    Response<dynamic> response = await requestCall();

    if (response.statusCode == 401 && _shouldTryRefresh(endpointUrl)) {
      final refreshed = await _authSessionService.refreshSession();
      if (refreshed) {
        response = await requestCall();
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
        requestCall: () => get(endpointUrl),
      );
    } catch (e) {
      log('[GET ERROR] $e');
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
        requestCall: () => post(endpointUrl, itemData),
      );
    } catch (e) {
      log('[POST ERROR] $e');
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
        requestCall: () => put(path, itemData),
      );
    } catch (e) {
      log('[PUT ERROR] $e');
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
        requestCall: () => delete(path),
      );
    } catch (e) {
      log('[DELETE ERROR] $e');
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }
}
