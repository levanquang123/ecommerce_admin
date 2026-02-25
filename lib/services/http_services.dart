import 'package:get/get.dart';
import '../utility/constants.dart';

class HttpService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = MAIN_URL;
    httpClient.timeout = const Duration(seconds: 30);

    httpClient.defaultContentType = 'application/json';

    super.onInit();
  }

  Future<Response> getItems({
    required String endpointUrl,
  }) async {
    try {
      return await get(endpointUrl);
    } catch (e) {
      return Response(
        statusCode: 500,
        body: {'error': e.toString()},
      );
    }
  }

  Future<Response> addItem({
    required String endpointUrl,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      return await post(endpointUrl, itemData);
    } catch (e) {
      return Response(
        statusCode: 500,
        body: {'message': e.toString()},
      );
    }
  }

  Future<Response> updateItem({
    required String endpointUrl,
    required String itemId,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      return await put('$endpointUrl/$itemId', itemData);
    } catch (e) {
      return Response(
        statusCode: 500,
        body: {'message': e.toString()},
      );
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  }) async {
    try {
      return await delete('$endpointUrl/$itemId');
    } catch (e) {
      return Response(
        statusCode: 500,
        body: {'message': e.toString()},
      );
    }
  }
}
