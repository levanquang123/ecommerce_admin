import '../../../models/brand.dart';
import '../data/brand_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/sub_category.dart';
import '../../../utility/snack_bar_helper.dart';

class BrandProvider extends ChangeNotifier {
  final BrandRepository _brandRepository;
  final DataProvider _dataProvider;

  final addBrandFormKey = GlobalKey<FormState>();
  TextEditingController brandNameCtrl = TextEditingController();
  SubCategory? selectedSubCategory;
  Brand? brandForUpdate;

  BrandProvider(this._dataProvider, this._brandRepository);

  Future<bool> addBrand() async {
    try {
      Map<String, dynamic> brand = {
        'name': brandNameCtrl.text,
        'subCategoryId': selectedSubCategory?.sId,
      };

      final apiResponse = await _brandRepository.createBrand(brand);

      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllBrands();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to add Brand: ${apiResponse.message}');
        return false;
      }

    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateBrand() async {
    try {
      if (brandForUpdate != null) {
        Map<String, dynamic> brand = {
          'name': brandNameCtrl.text,
          'subCategoryId': selectedSubCategory?.sId,
        };

        final apiResponse = await _brandRepository.updateBrand(
          brandId: brandForUpdate?.sId ?? '',
          data: brand,
        );

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllBrands();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update Brand: ${apiResponse.message}');
          return false;
        }

      }
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<void> deleteBrand(Brand brand) async {
    try {
      final apiResponse = await _brandRepository.deleteBrand(brand);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllBrands();
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitBrand() async {
    if (brandForUpdate != null) {
      return await updateBrand();
    } else {
      return await addBrand();
    }
  }
  //? set data for update on editing
  setDataForUpdateBrand(Brand? brand) {
    if (brand != null) {
      brandForUpdate = brand;
      brandNameCtrl.text = brand.name ?? '';
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == brand.subCategoryId?.sId);
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update brand
  clearFields() {
    brandNameCtrl.clear();
    selectedSubCategory = null;
    brandForUpdate = null;
  }

  updateUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    brandNameCtrl.dispose();
    super.dispose();
  }
}
