import 'dart:developer';
import 'package:flutter/cupertino.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant_type.dart';
import '../../../utility/snack_bar_helper.dart';
import '../data/variant_type_repository.dart';

class VariantsTypeProvider extends ChangeNotifier {
  final VariantTypeRepository _variantTypeRepository;
  final DataProvider _dataProvider;

  final addVariantsTypeFormKey = GlobalKey<FormState>();
  TextEditingController variantNameCtrl = TextEditingController();
  TextEditingController variantTypeCtrl = TextEditingController();

  VariantType? variantTypeForUpdate;

  VariantsTypeProvider(this._dataProvider, this._variantTypeRepository);

  Future<bool> addVariantType() async {
    try {
      final Map<String, dynamic> variantType = {
        'name': variantNameCtrl.text.trim(),
        'type': variantTypeCtrl.text.trim(),
      };

      final apiResponse =
          await _variantTypeRepository.createVariantType(variantType);

      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllVariantTypes();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
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

      final apiResponse = await _variantTypeRepository.updateVariantType(
        variantTypeId: variantTypeForUpdate?.sId ?? '',
        data: variantType,
      );

      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllVariantTypes();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
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
      final apiResponse =
          await _variantTypeRepository.deleteVariantType(variantType);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllVariantTypes();
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
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

  @override
  void dispose() {
    variantNameCtrl.dispose();
    variantTypeCtrl.dispose();
    super.dispose();
  }
}
