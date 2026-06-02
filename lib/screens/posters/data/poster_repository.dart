import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/poster.dart';

class PosterRepository {
  const PosterRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> createPoster(Object formData) async {
    final response = await _apiClient.addItem(
      endpointUrl: ApiEndpoints.posters,
      itemData: formData,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> updatePoster({
    required String posterId,
    required Object formData,
  }) async {
    final response = await _apiClient.updateItem(
      endpointUrl: ApiEndpoints.posters,
      itemId: posterId,
      itemData: formData,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> deletePoster(Poster poster) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: ApiEndpoints.posters,
      itemId: poster.sId ?? '',
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
