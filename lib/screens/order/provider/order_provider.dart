import 'dart:developer';

import '../../../models/order.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/data/data_provider.dart';
import '../../../utility/snack_bar_helper.dart';
import '../data/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final DataProvider _dataProvider;
  final orderFormKey = GlobalKey<FormState>();
  TextEditingController trackingUrlCtrl = TextEditingController();
  String selectedOrderStatus = 'pending';
  Order? orderForUpdate;

  OrderProvider(this._dataProvider, this._orderRepository);

  updateOrder() async {
    try {
      if (orderForUpdate != null) {
        Map<String, dynamic> order = {
          'trackingUrl': trackingUrlCtrl.text,
          'orderStatus': selectedOrderStatus
        };

        final apiResponse = await _orderRepository.updateOrder(
          orderId: orderForUpdate?.sId ?? '',
          data: order,
        );

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          log('Order updated');
          _dataProvider.getAllOrders();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update Order: ${apiResponse.message}');
        }
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  deleteOrder(Order order) async {
    try {
      final apiResponse = await _orderRepository.deleteOrder(order);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar('Order Deleted Successfully');
        _dataProvider.getAllOrders();
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  void setOrderForEdit(Order? order) {
    orderForUpdate = order;
    trackingUrlCtrl.text = order?.trackingUrl ?? '';
    selectedOrderStatus = order?.orderStatus ?? 'pending';
    notifyListeners();
  }

  void clearFields() {
    trackingUrlCtrl.clear();
    selectedOrderStatus = 'pending';
    orderForUpdate = null;
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    trackingUrlCtrl.dispose();
    super.dispose();
  }
}
