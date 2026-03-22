import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utility/constants.dart';

class HttpService extends GetConnect {
  final GetStorage _box = GetStorage();

  HttpService() {
    baseUrl = MAIN_URL;
    timeout = const Duration(seconds: 30);
    
    httpClient.baseUrl = MAIN_URL;
    
    // Log Request
    httpClient.addRequestModifier<dynamic>((request) {
      final token = _box.read(TOKEN);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      log('--- 🚀 [HTTP REQUEST] ---');
      log('URL: ${request.url}');
      log('Method: ${request.method}');
      log('Headers: ${request.headers}');
      return request;
    });

    // Log Response
    httpClient.addResponseModifier((request, response) {
      log('--- ✅ [HTTP RESPONSE] ---');
      log('URL: ${request.url}');
      log('Status Code: ${response.statusCode}');
      log('Body: ${response.body}');
      
      if (response.statusCode == 401) {
        log('⚠️ [AUTH] Unauthorized - Token expired or missing');
      }
      return response;
    });
  }

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      return await get(endpointUrl);
    } catch (e) {
      log('❌ [GET ERROR] $e');
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> addItem({required String endpointUrl, required dynamic itemData}) async {
    try {
      log('📤 Sending Data: $itemData');
      return await post(endpointUrl, itemData);
    } catch (e) {
      log('❌ [POST ERROR] $e');
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> updateItem({required String endpointUrl, required String itemId, required dynamic itemData}) async {
    try {
      return await put('$endpointUrl/$itemId', itemData);
    } catch (e) {
      log('❌ [PUT ERROR] $e');
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> deleteItem({required String endpointUrl, required String itemId}) async {
    try {
      return await delete('$endpointUrl/$itemId');
    } catch (e) {
      log('❌ [DELETE ERROR] $e');
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }
}
