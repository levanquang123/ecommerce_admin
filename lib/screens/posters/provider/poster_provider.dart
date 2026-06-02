import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/poster.dart';
import '../../../utility/image_multipart.dart';
import '../../../utility/snack_bar_helper.dart';
import '../data/poster_repository.dart';

class PosterProvider extends ChangeNotifier {
  final PosterRepository _posterRepository;
  final DataProvider _dataProvider;

  final addPosterFormKey = GlobalKey<FormState>();
  TextEditingController posterNameCtrl = TextEditingController();

  Poster? posterForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  PosterProvider(this._dataProvider, this._posterRepository);

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

      final apiResponse = await _posterRepository.createPoster(form);

      SnackBarHelper.hideSnackBar();
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
      final apiResponse = await _posterRepository.updatePoster(
        posterId: posterForUpdate?.sId ?? "",
        formData: formData,
      );

      if (apiResponse.success == true) {
        clearFields();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        _dataProvider.getAllPosters();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
            "Failed to update poster: ${apiResponse.message}");
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
      final apiResponse = await _posterRepository.deletePoster(poster);

      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar('Poster Deleted Successfully');
        _dataProvider.getAllPosters();
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
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
      formData['img'] = await imageMultipartFileFromXFile(imgXFile);
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

  @override
  void dispose() {
    posterNameCtrl.dispose();
    super.dispose();
  }
}
