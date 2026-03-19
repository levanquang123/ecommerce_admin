import 'dart:developer';
import 'dart:io';
import '../../../models/api_response.dart';
import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../services/http_services.dart';
import '../../../models/product.dart';
import '../../../utility/snack_bar_helper.dart';

class DashBoardProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addProductFormKey = GlobalKey<FormState>();

  //?text editing controllers in dashBoard screen
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescCtrl = TextEditingController();
  TextEditingController productQntCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productOffPriceCtrl = TextEditingController();

  //? dropdown value
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Brand? selectedBrand;
  VariantType? selectedVariantType;
  List<String> selectedVariants = [];

  Product? productForUpdate;
  File? selectedMainImage,
      selectedSecondImage,
      selectedThirdImage,
      selectedFourthImage,
      selectedFifthImage;
  XFile? mainImgXFile,
      secondImgXFile,
      thirdImgXFile,
      fourthImgXFile,
      fifthImgXFile;

  List<SubCategory> subCategoriesByCategory = [];
  List<Brand> brandsBySubCategory = [];
  List<String> variantsByVariantType = [];

  DashBoardProvider(this._dataProvider);

  Future<bool> addProduct() async {
    try {
      if (mainImgXFile == null) {
        SnackBarHelper.showErrorSnackBar('Please Choose A Image !');
        return false;
      }

      SnackBarHelper.showLoadingSnackBar('Adding product and uploading images...');

      final Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text.trim(),
        'description': productDescCtrl.text.trim(),
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'price': productPriceCtrl.text.trim(),
        'offerPrice': productOffPriceCtrl.text.trim().isEmpty
            ? productPriceCtrl.text.trim()
            : productOffPriceCtrl.text.trim(),
        'quantity': productQntCtrl.text.trim(),
      };

      if (selectedBrand?.sId != null && selectedBrand!.sId!.isNotEmpty) {
        formDataMap['proBrandId'] = selectedBrand?.sId;
      }
      
      if (selectedVariantType?.sId != null && selectedVariantType!.sId!.isNotEmpty) {
        formDataMap['proVariantTypeId'] = selectedVariantType?.sId;
      }

      if (selectedVariants.isNotEmpty) {
        formDataMap['proVariantId'] = selectedVariants;
      }

      final form = await createFormDataForMultipleImage(
        imgXFiles: [
          {'image1': mainImgXFile},
          {'image2': secondImgXFile},
          {'image3': thirdImgXFile},
          {'image4': fourthImgXFile},
          {'image5': fifthImgXFile},
        ],
        formData: formDataMap,
      );

      final response = await service.addItem(
        endpointUrl: 'products',
        itemData: form,
      );

      SnackBarHelper.hideSnackBar();

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          notifyListeners();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          await _dataProvider.getAllProducts();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message);
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Request failed.');
        return false;
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateProduct() async {
    try {
      if (productForUpdate == null) return false;

      SnackBarHelper.showLoadingSnackBar('Updating product details...');

      final Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text.trim(),
        'description': productDescCtrl.text.trim(),
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'price': productPriceCtrl.text.trim(),
        'offerPrice': productOffPriceCtrl.text.trim().isEmpty
            ? productPriceCtrl.text.trim()
            : productOffPriceCtrl.text.trim(),
        'quantity': productQntCtrl.text.trim(),
      };

      if (selectedBrand?.sId != null && selectedBrand!.sId!.isNotEmpty) {
        formDataMap['proBrandId'] = selectedBrand?.sId;
      } else {
        formDataMap['proBrandId'] = null;
      }
      
      if (selectedVariantType?.sId != null && selectedVariantType!.sId!.isNotEmpty) {
        formDataMap['proVariantTypeId'] = selectedVariantType?.sId;
      } else {
        formDataMap['proVariantTypeId'] = null;
      }

      if (selectedVariants.isNotEmpty) {
        formDataMap['proVariantId'] = selectedVariants;
      }

      final form = await createFormDataForMultipleImage(
        imgXFiles: [
          {'image1': mainImgXFile},
          {'image2': secondImgXFile},
          {'image3': thirdImgXFile},
          {'image4': fourthImgXFile},
          {'image5': fifthImgXFile},
        ],
        formData: formDataMap,
      );

      final response = await service.updateItem(
        endpointUrl: 'products',
        itemData: form,
        itemId: productForUpdate?.sId ?? '',
      );

      SnackBarHelper.hideSnackBar();

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          await _dataProvider.getAllProducts();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message);
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Update failed.');
        return false;
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(Product product) async {
    try {
      final Response response = await service.deleteItem(
        endpointUrl: 'products',
        itemId: product.sId ?? '',
      );
      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          _dataProvider.getAllProducts();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message);
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Delete failed.');
        return false;
      }
    } catch (e) {
      SnackBarHelper.hideSnackBar();
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> submitProduct() async {
    if (productForUpdate != null) {
      return await updateProduct();
    } else {
      return await addProduct();
    }
  }

  void pickImage({required int imageCardNumber}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (imageCardNumber == 1) {
        selectedMainImage = File(image.path);
        mainImgXFile = image;
      } else if (imageCardNumber == 2) {
        selectedSecondImage = File(image.path);
        secondImgXFile = image;
      } else if (imageCardNumber == 3) {
        selectedThirdImage = File(image.path);
        thirdImgXFile = image;
      } else if (imageCardNumber == 4) {
        selectedFourthImage = File(image.path);
        fourthImgXFile = image;
      } else if (imageCardNumber == 5) {
        selectedFifthImage = File(image.path);
        fifthImgXFile = image;
      }
      notifyListeners();
    }
  }

  Future<FormData> createFormDataForMultipleImage({
    required List<Map<String, XFile?>>? imgXFiles,
    required Map<String, dynamic> formData,
  }) async {
    if (imgXFiles != null) {
      for (int i = 0; i < imgXFiles.length; i++) {
        XFile? imgXFile = imgXFiles[i]['image' + (i + 1).toString()];
        if (imgXFile != null) {
          if (kIsWeb) {
            String fileName = imgXFile.name;
            Uint8List byteImg = await imgXFile.readAsBytes();
            formData['image' + (i + 1).toString()] =
                MultipartFile(byteImg, filename: fileName);
          } else {
            String filePath = imgXFile.path;
            String fileName = filePath.split('/').last;
            formData['image' + (i + 1).toString()] =
                await MultipartFile(filePath, filename: fileName);
          }
        }
      }
    }
    return FormData(formData);
  }

  filterSubCategory(Category category) {
    selectedSubCategory = null;
    selectedBrand = null;
    subCategoriesByCategory.clear();
    selectedCategory = category;
    final newListSubCategory = _dataProvider.subCategories
        .where((subcategory) => subcategory.categoryId?.sId == category.sId)
        .toList();
    subCategoriesByCategory = newListSubCategory;
    notifyListeners();
  }

  filterBrand(SubCategory subCategory) {
    selectedBrand = null;
    brandsBySubCategory.clear();
    selectedSubCategory = subCategory;
    final newListBrand = _dataProvider.brands
        .where((brand) => brand.subCategoryId?.sId == subCategory.sId)
        .toList();
    brandsBySubCategory = newListBrand;
    notifyListeners();
  }

  filterVariant(VariantType variantType) {
    selectedVariants = [];
    selectedVariantType = variantType;
    final newListVariant = _dataProvider.variants
        .where((variant) => variant.variantTypeId?.sId == variantType.sId)
        .toList();
    final List<String> variantNames =
        newListVariant.map((variant) => variant.name ?? '').toList();
    variantsByVariantType = variantNames;
    notifyListeners();
  }

  setDataForUpdateProduct(Product? product) {
    if (product != null) {
      productForUpdate = product;

      productNameCtrl.text = product.name ?? '';
      productDescCtrl.text = product.description ?? '';
      productPriceCtrl.text = product.price.toString();
      productOffPriceCtrl.text = '${product.offerPrice}';
      productQntCtrl.text = '${product.quantity}';

      selectedCategory = _dataProvider.categories.firstWhereOrNull(
          (element) => element.sId == product.proCategoryId?.sId);

      subCategoriesByCategory = _dataProvider.subCategories
          .where((subcategory) =>
              subcategory.categoryId?.sId == product.proCategoryId?.sId)
          .toList();
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == product.proSubCategoryId?.sId);

      brandsBySubCategory = _dataProvider.brands
          .where((brand) =>
              brand.subCategoryId?.sId == product.proSubCategoryId?.sId)
          .toList();
      selectedBrand = _dataProvider.brands.firstWhereOrNull(
          (element) => element.sId == product.proBrandId?.sId);

      selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull(
          (element) => element.sId == product.proVariantTypeId?.sId);

      final newListVariant = _dataProvider.variants
          .where((variant) =>
              variant.variantTypeId?.sId == product.proVariantTypeId?.sId)
          .toList();
      final List<String> variantNames =
          newListVariant.map((variant) => variant.name ?? '').toList();
      variantsByVariantType = variantNames;
      selectedVariants = product.proVariantId ?? [];
    } else {
      clearFields();
    }
    notifyListeners();
  }

  clearFields() {
    productNameCtrl.clear();
    productDescCtrl.clear();
    productPriceCtrl.clear();
    productOffPriceCtrl.clear();
    productQntCtrl.clear();

    selectedMainImage = null;
    selectedSecondImage = null;
    selectedThirdImage = null;
    selectedFourthImage = null;
    selectedFifthImage = null;

    mainImgXFile = null;
    secondImgXFile = null;
    thirdImgXFile = null;
    fourthImgXFile = null;
    fifthImgXFile = null;

    selectedCategory = null;
    selectedSubCategory = null;
    selectedBrand = null;
    selectedVariantType = null;
    selectedVariants = [];

    productForUpdate = null;

    subCategoriesByCategory = [];
    brandsBySubCategory = [];
    variantsByVariantType = [];

    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }
}
