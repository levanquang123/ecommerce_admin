import 'dart:io';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/api_response.dart';
import '../../../models/poster.dart';
import '../../../utility/snack_bar_helper.dart';

class PosterProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addPosterFormKey = GlobalKey<FormState>();
  TextEditingController posterNameCtrl = TextEditingController();

  Poster? posterForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  PosterProvider(this._dataProvider);

  Future<bool> addPoster() async {
    try {
      SnackBarHelper.showLoadingSnackBar('Adding poster...');
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar("Please Choose A Image !");
        return false;
      }

      Map<String, dynamic> formDataMap = {
        "posterName": posterNameCtrl.text,
        "image": "no-data",
      };

      final FormData form =
      await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response =
      await service.addItem(endpointUrl: "posters", itemData: form);

      SnackBarHelper.hideSnackBar();
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar("Poster Added Successfully");
          _dataProvider.getAllPosters();
          clearFields();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              "Failed to add poster: ${apiResponse.message}");
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            response.body?['message'] ?? response.statusText ?? "Server Error");
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar("Error: $e");
      return false;
    }
  }

  Future<bool> updatePoster() async {
    try {
      SnackBarHelper.showLoadingSnackBar('Updating poster...');
      if (posterForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("Poster not found for update");
        return false;
      }

      Map<String, dynamic> formDataMap = {
        "posterName": posterNameCtrl.text,
        "image": posterForUpdate?.imageUrl ?? "",
      };

      FormData formData =
      await createFormData(imgXFile: imgXFile, formData: formDataMap);

      SnackBarHelper.hideSnackBar();
      final response = await service.updateItem(
        endpointUrl: "posters",
        itemId: posterForUpdate?.sId ?? "",
        itemData: formData,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message ?? "Updated");
          _dataProvider.getAllPosters();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              "Failed to update poster: ${apiResponse.message}");
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? response.statusText ?? "Server Error",
        );
        return false;
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar("Error: $e");
      return false;
    }
  }

  Future<bool> submitPoster() async {
    if (posterForUpdate != null) {
      return await updatePoster();
    } else {
      return await addPoster();
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

  Future<void> deletePoster(Poster poster) async {
    try {
      Response response = await service.deleteItem(
        endpointUrl: 'posters',
        itemId: poster.sId ?? "",
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Poster Deleted Successfully');
          _dataProvider.getAllPosters();
        } else {
          SnackBarHelper.showErrorSnackBar(
              apiResponse.message ?? "Failed to delete poster");
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          'Error ${response.body?['message'] ?? response.statusText}',
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar("Error: $e");
      rethrow;
    }
  }

  setDataForUpdatePoster(Poster? poster) {
    if (poster != null) {
      clearFields();
      posterForUpdate = poster;
      posterNameCtrl.text = poster.posterName ?? '';
    } else {
      clearFields();
    }
  }

  Future<FormData> createFormData({
    required XFile? imgXFile,
    required Map<String, dynamic> formData,
  }) async {
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

  clearFields() {
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    posterForUpdate = null;
  }
}