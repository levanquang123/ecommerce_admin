import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/api_response.dart';
import '../../../models/variant_type.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class VariantsTypeProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addVariantsTypeFormKey = GlobalKey<FormState>();
  TextEditingController variantNameCtrl = TextEditingController();
  TextEditingController variantTypeCtrl = TextEditingController();

  VariantType? variantTypeForUpdate;

  VariantsTypeProvider(this._dataProvider);

  Future<bool> addVariantType() async {
    try {
      final Map<String, dynamic> variantType = {
        'name': variantNameCtrl.text.trim(),
        'type': variantTypeCtrl.text.trim(),
      };

      final response = await service.addItem(
        endpointUrl: 'variantTypes',
        itemData: variantType,
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllVariantTypes();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message);
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? response.statusText,
        );
        return false;
      }
    } catch (e) {
      log(e.toString());
      SnackBarHelper.showErrorSnackBar(e.toString());
      return false;
    }
  }

  Future<bool> updateVariantType() async {
    try {
      if (variantTypeForUpdate == null) return false;

      final Map<String, dynamic> variantType = {
        'name': variantNameCtrl.text.trim(),
        'type': variantTypeCtrl.text.trim(),
      };

      final response = await service.updateItem(
        endpointUrl: 'variantTypes',
        itemData: variantType,
        itemId: variantTypeForUpdate?.sId ?? '',
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllVariantTypes();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message);
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? response.statusText,
        );
        return false;
      }
    } catch (e) {
      log(e.toString());
      SnackBarHelper.showErrorSnackBar(e.toString());
      return false;
    }
  }

  Future<void> deleteVariantType(VariantType variantType) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'variantTypes',
        itemId: variantType.sId ?? '',
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllVariantTypes();
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? response.statusText,
        );
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> submitVariantType() async {
    if (variantTypeForUpdate != null) {
      return await updateVariantType();
    } else {
      return await addVariantType();
    }
  }

  setDataForUpdateVariantTYpe(VariantType? variantType) {
    if (variantType != null) {
      variantTypeForUpdate = variantType;
      variantNameCtrl.text = variantType.name ?? '';
      variantTypeCtrl.text = variantType.type ?? '';
    } else {
      clearFields();
    }
    notifyListeners();
  }

  clearFields() {
    variantNameCtrl.clear();
    variantTypeCtrl.clear();
    variantTypeForUpdate = null;
    notifyListeners();
  }
}