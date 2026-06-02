import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/coupon.dart';

class CouponRepository {
  const CouponRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> createCoupon(Map<String, dynamic> data) async {
    final response = await _apiClient.addItem(
      endpointUrl: ApiEndpoints.couponCodes,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> updateCoupon({
    required String couponId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.updateItem(
      endpointUrl: ApiEndpoints.couponCodes,
      itemId: couponId,
      itemData: data,
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse> deleteCoupon(Coupon coupon) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: ApiEndpoints.couponCodes,
      itemId: coupon.sId ?? '',
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
