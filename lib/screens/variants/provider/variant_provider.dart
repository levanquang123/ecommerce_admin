import 'dart:developer';
import '../../../models/variant_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';
import '../../../utility/snack_bar_helper.dart';
import '../data/variant_repository.dart';

class VariantsProvider extends ChangeNotifier {
  final VariantRepository _variantRepository;
  final DataProvider _dataProvider;

  final addVariantsFormKey = GlobalKey<FormState>();
  TextEditingController variantCtrl = TextEditingController();

  VariantType? selectedVariantType;
  Variant? variantForUpdate;

  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];

  List<Variant> get allVariants => _allVariants;
  List<Variant> get filteredVariants => _filteredVariants;

  VariantsProvider(this._dataProvider, this._variantRepository);

  Future<bool> addVariant() async {
    try {
      SnackBarHelper.showLoadingSnackBar('Adding variant...');
      final Map<String, dynamic> variant = {
        'name': variantCtrl.text.trim(),
        'variantTypeId': selectedVariantType?.sId,
      };

      final apiResponse = await _variantRepository.createVariant(variant);

      SnackBarHelper.hideSnackBar();
      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllVariant();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
        return false;
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      log(e.toString());
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateVariant() async {
    try {
      if (variantForUpdate == null) return false;

      SnackBarHelper.showLoadingSnackBar('Updating variant...');
      final Map<String, dynamic> variant = {
        'name': variantCtrl.text.trim(),
        'variantTypeId': selectedVariantType?.sId,
      };

      final apiResponse = await _variantRepository.updateVariant(
        variantId: variantForUpdate?.sId ?? '',
        data: variant,
      );

      SnackBarHelper.hideSnackBar();
      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllVariant();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
        return false;
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
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
      final apiResponse = await _variantRepository.deleteVariant(variant);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllVariant();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
        return false;
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      log(e.toString());
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<List<Variant>> getAllVariant({bool showSnack = false}) async {
    try {
      final apiResponse = await _variantRepository.getAllVariants();
      if (apiResponse.success == true) {
        _allVariants = apiResponse.data ?? [];
        _filteredVariants = List.from(_allVariants);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else if (showSnack) {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
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

  @override
  void dispose() {
    variantCtrl.dispose();
    super.dispose();
  }
}
