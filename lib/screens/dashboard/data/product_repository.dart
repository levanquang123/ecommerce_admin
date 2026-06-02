import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/product.dart';

class ProductRepository {
  const ProductRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> createProduct(Object formData) async {
    final response = await _apiClient.addItem(
      endpointUrl: ApiEndpoints.products,
      itemData: formData,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> updateProduct({
    required String productId,
    required Object formData,
  }) async {
    final response = await _apiClient.updateItem(
      endpointUrl: ApiEndpoints.products,
      itemId: productId,
      itemData: formData,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> deleteProduct(Product product) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: ApiEndpoints.products,
      itemId: product.sId ?? '',
    );
    return _parseMutationResponse(response);
  }

  ApiResponse _parseMutationResponse(Response response) {
    if (response.isOk && response.body is Map) {
      final body = (response.body as Map).cast<String, dynamic>();
      return ApiResponse.fromJson(body, null);
    }

    final body = response.body;
    final message = body is Map ? body['message']?.toString() : response.statusText;
    return ApiResponse(success: false, message: message ?? 'Server Error');
  }
}
