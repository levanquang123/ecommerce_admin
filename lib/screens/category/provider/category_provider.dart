import 'dart:io';
import 'package:admin/utility/snack_bar_helper.dart';
import '../../../models/api_response.dart';
import '../data/category_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../utility/image_multipart.dart';

class CategoryProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final CategoryRepository _categoryRepository;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider, this._categoryRepository);

  Future<bool> addCategory() async {
    try {
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar("Please Choose A Image !");
        return false;
      }

      SnackBarHelper.showLoadingSnackBar(
          'Adding category and uploading image...');

      Map<String, dynamic> formDataMap = {
        "name": categoryNameCtrl.text,
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final ApiResponse apiResponse =
          await _categoryRepository.createCategory(form);

      SnackBarHelper.hideSnackBar();

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar("Category Added Successfully");
        _dataProvider.getAllCategory();
        clearFields();
        return true;
      }

      SnackBarHelper.showErrorSnackBar(
          "Failed to add category: ${apiResponse.message}");
      return false;
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      SnackBarHelper.showErrorSnackBar("Error: $e");
      return false;
    }
  }

  Future<bool> updateCategory() async {
    try {
      SnackBarHelper.showLoadingSnackBar('Updating category...');
      Map<String, dynamic> formDataMap = {
        "name": categoryNameCtrl.text,
        "image": categoryForUpdate?.image ?? "",
      };

      FormData formData =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final ApiResponse apiResponse = await _categoryRepository.updateCategory(
        categoryId: categoryForUpdate?.sId ?? "",
        formData: formData,
      );

      SnackBarHelper.hideSnackBar();

      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllCategory();
        return true;
      }

      SnackBarHelper.showErrorSnackBar(
        "Failed to update category: ${apiResponse.message}",
      );
      return false;
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      SnackBarHelper.showErrorSnackBar("Error: $e");
      return false;
    }
  }

  Future<bool> submitCategory() async {
    if (categoryForUpdate != null) {
      return await updateCategory();
    } else {
      return await addCategory();
    }
  }

  Future<void> deleteCategory(Category category) async {
    try {
      final ApiResponse apiResponse =
          await _categoryRepository.deleteCategory(category);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar(
          'Category Deleted Successfully',
        );
        _dataProvider.getAllCategory();
        return;
      }

      SnackBarHelper.showErrorSnackBar('Error ${apiResponse.message}');
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      rethrow;
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  Future<FormData> createFormData(
      {required XFile? imgXFile,
      required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      formData['img'] = await imageMultipartFileFromXFile(imgXFile);
    }
    final FormData form = FormData(formData);
    return form;
  }

  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
    notifyListeners();
  }

  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
    notifyListeners();
  }

  @override
  void dispose() {
    categoryNameCtrl.dispose();
    super.dispose();
  }
}
