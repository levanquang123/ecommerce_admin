import 'dart:developer';
import '../../../models/variant_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/api_response.dart';
import '../../../models/variant.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class VariantsProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addVariantsFormKey = GlobalKey<FormState>();
  TextEditingController variantCtrl = TextEditingController();

  VariantType? selectedVariantType;
  Variant? variantForUpdate;

  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];

  List<Variant> get allVariants => _allVariants;
  List<Variant> get filteredVariants => _filteredVariants;

  VariantsProvider(this._dataProvider);

  Future<bool> addVariant() async {
    try {
      final Map<String, dynamic> variant = {
        'name': variantCtrl.text.trim(),
        'variantTypeId': selectedVariantType?.sId,
      };

      final response = await service.addItem(
        endpointUrl: 'variants',
        itemData: variant,
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllVariant();
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
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateVariant() async {
    try {
      if (variantForUpdate == null) return false;

      final Map<String, dynamic> variant = {
        'name': variantCtrl.text.trim(),
        'variantTypeId': selectedVariantType?.sId,
      };

      final response = await service.updateItem(
        endpointUrl: 'variants',
        itemData: variant,
        itemId: variantForUpdate?.sId ?? '',
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllVariant();
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
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> submitVariant() async {
    if (variantForUpdate != null) {
      return await updateVariant();
    } else {
      return await addVariant();
    }
  }

  Future<bool> deleteVariant(Variant variant) async {
    try {
      final Response response = await service.deleteItem(
        endpointUrl: 'variants',
        itemId: variant.sId ?? '',
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllVariant();
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
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<List<Variant>> getAllVariant({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "variants");
      if (response.isOk) {
        ApiResponse<List<Variant>> apiResponse =
        ApiResponse<List<Variant>>.fromJson(
          response.body,
              (json) => (json as List)
              .map((item) => Variant.fromJson(item))
              .toList(),
        );

        _allVariants = apiResponse.data ?? [];
        _filteredVariants = List.from(_allVariants);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredVariants;
  }

  void filterVariant(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredVariants = List.from(_allVariants);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredVariants = _allVariants.where((variant) {
        final name = (variant.name ?? "").toLowerCase();
        final typeName = (variant.variantTypeId?.name ?? "").toLowerCase();
        return name.contains(lowerKeyWord) || typeName.contains(lowerKeyWord);
      }).toList();
    }
    notifyListeners();
  }

  setDataForUpdateVariant(Variant? variant) {
    if (variant != null) {
      variantForUpdate = variant;
      variantCtrl.text = variant.name ?? '';
      selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull(
            (element) => element.sId == variant.variantTypeId?.sId,
      );
    } else {
      clearFields();
    }
    notifyListeners();
  }

  clearFields() {
    variantCtrl.clear();
    selectedVariantType = null;
    variantForUpdate = null;
    notifyListeners();
  }

  void updateUI() {
    notifyListeners();
  }
}