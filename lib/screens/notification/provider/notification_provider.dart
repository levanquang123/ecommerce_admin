import 'dart:developer';

import '../../../models/my_notification.dart';
import '../../../models/notification_result.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/data/data_provider.dart';
import '../../../utility/snack_bar_helper.dart';
import '../data/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;
  final DataProvider _dataProvider;

  final sendNotificationFormKey = GlobalKey<FormState>();

  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  TextEditingController imageUrlCtrl = TextEditingController();

  NotificationResult? notificationResult;

  NotificationProvider(this._dataProvider, this._notificationRepository);

  sendNotification() async {
    try {
      Map<String, dynamic> notification = {
        "title": titleCtrl.text.trim(),
        "description": descriptionCtrl.text.trim(),
        "imageUrl": imageUrlCtrl.text.trim(),
      };

      final apiResponse =
          await _notificationRepository.sendNotification(notification);
      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
        log('Notification send');
        _dataProvider.getAllNotifications();
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to send Notification: ${apiResponse.message}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  deleteNotification(MyNotification notification) async {
    try {
      final apiResponse =
          await _notificationRepository.deleteNotification(notification);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar(
            'Notification Deleted Successfully');
        _dataProvider.getAllNotifications();
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  getNotificationInfo(MyNotification? notification) async {
    try {
      if (notification == null) {
        SnackBarHelper.showErrorSnackBar('Something went wrong');
        return;
      }

      final apiResponse =
          await _notificationRepository.getNotificationInfo(notification);

      if (apiResponse.success == true) {
        notificationResult = apiResponse.data;
        log('notification fetch success');
        notifyListeners();
        return null;
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to Fetch Data: ${apiResponse.message}');
        return 'Failed to Fetch Data';
      }
    } catch (e) {
      rethrow;
    }
  }

  clearFields() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    imageUrlCtrl.clear();
  }

  updateUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    imageUrlCtrl.dispose();
    super.dispose();
  }
}
