import 'dart:io';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../models/api_response.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider);

  Future<bool> addCategory() async {
    try {
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar("Please Choose A Image !");
        return false;
      }

      SnackBarHelper.showLoadingSnackBar('Adding category and uploading image...');

      Map<String, dynamic> formDataMap = {
        "name": categoryNameCtrl.text,
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response =
          await service.addItem(endpointUrl: "categories", itemData: form);

      SnackBarHelper.hideSnackBar();

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar("Category Added Successfully");
          _dataProvider.getAllCategory();
          clearFields();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              "Failed to add category: ${apiResponse.message}");
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            response.body?['message'] ?? response.statusText ?? "Server Error");
        return false;
      }
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

      final response = await service.updateItem(
        endpointUrl: "categories",
        itemId: categoryForUpdate?.sId ?? "",
        itemData: formData,
      );

      SnackBarHelper.hideSnackBar();

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message ?? "Updated");
          _dataProvider.getAllCategory();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update category: ${apiResponse.message}",
          );
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? response.statusText ?? "Server Error",
        );
        return false;
      }
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
      Response response = await service.deleteItem(
        endpointUrl: 'categories',
        itemId: category.sId ?? "",
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(
            'Category Deleted Successfully',
          );
          _dataProvider.getAllCategory();
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          'Error ${response.body?['message'] ?? response.statusText}',
        );
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      print(e);
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
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
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
}
