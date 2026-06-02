import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/sub_category.dart';

class SubCategoryRepository {
  const SubCategoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> createSubCategory(Map<String, dynamic> data) async {
    final response = await _apiClient.addItem(
      endpointUrl: ApiEndpoints.subCategories,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> updateSubCategory({
    required String subCategoryId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.updateItem(
      endpointUrl: ApiEndpoints.subCategories,
      itemId: subCategoryId,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> deleteSubCategory(SubCategory subCategory) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: ApiEndpoints.subCategories,
      itemId: subCategory.sId ?? '',
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
