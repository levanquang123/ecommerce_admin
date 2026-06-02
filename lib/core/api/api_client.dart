import 'package:get/get.dart';

abstract class ApiClient {
  Future<Response> getItems({required String endpointUrl});

  Future<Response> addItem({
    required String endpointUrl,
    required Object itemData,
  });

  Future<Response> updateItem({
    required String endpointUrl,
    required String itemId,
    required Object itemData,
  });

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  });
}
