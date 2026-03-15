import 'package:get/get_connect.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utility/constants.dart';

class HttpService extends GetConnect {
  final GetStorage _box = GetStorage();

  HttpService() {
    baseUrl = MAIN_URL;
    timeout = const Duration(seconds: 30);
    
    httpClient.baseUrl = MAIN_URL;
    httpClient.addRequestModifier<dynamic>((request) {
      final token = _box.read('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
  }

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      return await get(endpointUrl);
    } catch (e) {
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> addItem({required String endpointUrl, required dynamic itemData}) async {
    try {
      return await post(endpointUrl, itemData);
    } catch (e) {
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> updateItem({required String endpointUrl, required String itemId, required dynamic itemData}) async {
    try {
      return await put('$endpointUrl/$itemId', itemData);
    } catch (e) {
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }

  Future<Response> deleteItem({required String endpointUrl, required String itemId}) async {
    try {
      return await delete('$endpointUrl/$itemId');
    } catch (e) {
      return Response(body: {'message': e.toString()}, statusCode: 500);
    }
  }
}
