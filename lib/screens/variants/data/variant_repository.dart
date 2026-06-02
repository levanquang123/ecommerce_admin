import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/variant.dart';

class VariantRepository {
  const VariantRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> createVariant(Map<String, dynamic> data) async {
    final response = await _apiClient.addItem(
      endpointUrl: ApiEndpoints.variants,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> updateVariant({
    required String variantId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.updateItem(
      endpointUrl: ApiEndpoints.variants,
      itemId: variantId,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> deleteVariant(Variant variant) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: ApiEndpoints.variants,
      itemId: variant.sId ?? '',
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse<List<Variant>>> getAllVariants() async {
    final response = await _apiClient.getItems(endpointUrl: ApiEndpoints.variants);
    if (response.isOk && response.body is Map) {
      final body = (response.body as Map).cast<String, dynamic>();
      return ApiResponse<List<Variant>>.fromJson(
        body,
        (json) => (json as List).map((item) => Variant.fromJson(item)).toList(),
      );
    }

    return ApiResponse<List<Variant>>(
      success: false,
      message: _errorMessage(response),
      data: const [],
    );
  }

  ApiResponse _parseMutationResponse(Response response) {
    if (response.isOk && response.body is Map) {
      final body = (response.body as Map).cast<String, dynamic>();
      return ApiResponse.fromJson(body, null);
    }
    return ApiResponse(success: false, message: _errorMessage(response));
  }

  String _errorMessage(Response response) {
    final body = response.body;
    return body is Map
        ? body['message']?.toString() ?? 'Server Error'
        : response.statusText ?? 'Server Error';
  }
}
