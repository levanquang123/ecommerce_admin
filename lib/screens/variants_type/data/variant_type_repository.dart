import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/variant_type.dart';

class VariantTypeRepository {
  const VariantTypeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> createVariantType(Map<String, dynamic> data) async {
    final response = await _apiClient.addItem(
      endpointUrl: ApiEndpoints.variantTypes,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> updateVariantType({
    required String variantTypeId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.updateItem(
      endpointUrl: ApiEndpoints.variantTypes,
      itemId: variantTypeId,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> deleteVariantType(VariantType variantType) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: ApiEndpoints.variantTypes,
      itemId: variantType.sId ?? '',
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
