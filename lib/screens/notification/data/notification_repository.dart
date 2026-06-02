import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../models/api_response.dart';
import '../../../models/my_notification.dart';
import '../../../models/notification_result.dart';

class NotificationRepository {
  const NotificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse> sendNotification(Map<String, dynamic> data) async {
    final response = await _apiClient.addItem(
      endpointUrl: 'notification/send-notification',
      itemData: data,
    );
    return _parseMutationResponse(
      response,
      parser: (json) => MyNotification.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse> deleteNotification(MyNotification notification) async {
    final response = await _apiClient.deleteItem(
      endpointUrl: 'notification/delete-notification',
      itemId: notification.sId ?? '',
    );
    return _parseMutationResponse(response);
  }

  Future<ApiResponse<NotificationResult>> getNotificationInfo(
    MyNotification notification,
  ) async {
    final response = await _apiClient.getItems(
      endpointUrl: 'notification/track-notification/${notification.notificationId}',
    );

    if (response.isOk && response.body is Map) {
      final body = (response.body as Map).cast<String, dynamic>();
      return ApiResponse<NotificationResult>.fromJson(
        body,
        (json) => NotificationResult.fromJson(json as Map<String, dynamic>),
      );
    }

    return ApiResponse<NotificationResult>(
      success: false,
      message: _errorMessage(response),
    );
  }

  ApiResponse _parseMutationResponse(
    Response response, {
    Object? Function(Object? json)? parser,
  }) {
    if (response.isOk && response.body is Map) {
      final body = (response.body as Map).cast<String, dynamic>();
      return ApiResponse.fromJson(body, parser);
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
