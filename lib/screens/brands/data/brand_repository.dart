import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/brand.dart';

class BrandRepository {
  const BrandRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> createBrand(Map<String, dynamic> data) async {
    final response = await _apiClient.addItem(
      endpointUrl: ApiEndpoints.brands,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> updateBrand({
    required String brandId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.updateItem(
      endpointUrl: ApiEndpoints.brands,
      itemId: brandId,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> deleteBrand(Brand brand) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: ApiEndpoints.brands,
      itemId: brand.sId ?? '',
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
