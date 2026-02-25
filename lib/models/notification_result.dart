class NotificationResult {
  final String? platform;
  final int? successDelivery;
  final int? failedDelivery;
  final int? erroredDelivery;
  final int? openedNotification;

  const NotificationResult(
      {this.platform,
      this.successDelivery,
      this.failedDelivery,
      this.erroredDelivery,
      this.openedNotification});

  factory NotificationResult.fromJson(Map<String, dynamic> json) {
    return NotificationResult(
      platform: json['platform'],
      successDelivery: json['success_delivery'],
      failedDelivery: json['failed_delivery'],
      erroredDelivery: json['errored_delivery'],
      openedNotification: json['opened_notification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'success_delivery': this.successDelivery,
      'failed_delivery': this.failedDelivery,
      'errored_delivery': this.erroredDelivery,
      'opened_notification': this.openedNotification,
    };
  }
}
