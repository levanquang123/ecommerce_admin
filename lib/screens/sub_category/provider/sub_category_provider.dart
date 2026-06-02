import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../utility/snack_bar_helper.dart';
import '../data/sub_category_repository.dart';

class SubCategoryProvider extends ChangeNotifier {
  final SubCategoryRepository _subCategoryRepository;
  final DataProvider _dataProvider;

  final addSubCategoryFormKey = GlobalKey<FormState>();
  TextEditingController subCategoryNameCtrl = TextEditingController();
  Category? selectedCategory;
  SubCategory? subCategoryForUpdate;

  SubCategoryProvider(this._dataProvider, this._subCategoryRepository);

  Future<bool> addSubCategory() async {
    try {
      SnackBarHelper.showLoadingSnackBar('Adding sub category...');
      Map<String, dynamic> subCategory = {
        'name': subCategoryNameCtrl.text,
        'categoryId': selectedCategory?.sId,
      };

      final apiResponse =
          await _subCategoryRepository.createSubCategory(subCategory);

      SnackBarHelper.hideSnackBar();
      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllSubCategory();
        log('Sub category added');
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to add Sub Category: ${apiResponse.message}');
        return false;
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateSubCategory() async {
    try {
      if (subCategoryForUpdate != null) {
        SnackBarHelper.showLoadingSnackBar('Updating sub category...');
        Map<String, dynamic> subCategory = {
          'name': subCategoryNameCtrl.text,
          'categoryId': selectedCategory?.sId
        };

        final apiResponse = await _subCategoryRepository.updateSubCategory(
          subCategoryId: subCategoryForUpdate?.sId ?? '',
          data: subCategory,
        );

        SnackBarHelper.hideSnackBar();
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          log('Sub Category Updated');
          _dataProvider.getAllSubCategory();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update Sub Category: ${apiResponse.message}');
          return false;
        }
      }
      return false;
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<void> deleteSubCategory(SubCategory subCategory) async {
    try {
      final apiResponse =
          await _subCategoryRepository.deleteSubCategory(subCategory);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar("${apiResponse.message}");
        _dataProvider.getAllSubCategory();
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      rethrow;
    }
  }

  Future<bool> submitSubCategory() async {
    if (subCategoryForUpdate != null) {
      return await updateSubCategory();
    } else {
      return await addSubCategory();
    }
  }

  setDataForUpdateSubCategory(SubCategory? subCategory) {
    if (subCategory != null) {
      subCategoryForUpdate = subCategory;
      subCategoryNameCtrl.text = subCategory.name ?? '';
      selectedCategory = _dataProvider.categories.firstWhereOrNull(
          (element) => element.sId == subCategory.categoryId?.sId);
    } else {
      clearFields();
    }
  }

  clearFields() {
    subCategoryNameCtrl.clear();
    selectedCategory = null;
    subCategoryForUpdate = null;
    notifyListeners();
  }

  updateUi() {
    notifyListeners();
  }

  @override
  void dispose() {
    subCategoryNameCtrl.dispose();
    super.dispose();
  }
}
