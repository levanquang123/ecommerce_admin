import 'package:get/get.dart';

String apiErrorMessage(Response response, {String fallback = 'Server Error'}) {
  final body = response.body;
  if (body is Map) {
    final message = body['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
  }

  final statusText = response.statusText;
  if (statusText != null && statusText.trim().isNotEmpty) {
    return statusText;
  }

  return fallback;
}
