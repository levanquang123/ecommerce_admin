import 'dart:io';
import 'package:admin/core/data/data_provider.dart';
import 'package:admin/models/category.dart';
import 'package:admin/services/http_services.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CategoryProvider extends ChangeNotifier {
  final HttpService httpService = HttpService();
  final TextEditingController categoryNameCtrl = TextEditingController();
  final addCategoryFormKey = GlobalKey<FormState>();
  Category? categoryForUpdate;
  final DataProvider _dataProvider;

  CategoryProvider(this._dataProvider);

  File? selectedImage;
  XFile? imgXFile;

  void pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imgXFile = image;
      selectedImage = File(image.path);
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
        String fileName = imgXFile.path.split("/").last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData["img"] = multipartFile;
    }
    return FormData(formData);
  }

  void setUpdateForCategory(Category? category) {
    clearFields();
    if (category != null) {
      categoryNameCtrl.text = category.name ?? "";
      categoryForUpdate = category;
    }
    notifyListeners();
  }

  void clearFields() {
    categoryNameCtrl.clear();
    categoryForUpdate = null;
    selectedImage = null;
    imgXFile = null;
    notifyListeners();
  }

  @override
  void dispose() {
    categoryNameCtrl.dispose();
    super.dispose();
  }
}