import 'dart:convert';
import 'dart:io';

import '../../../models/api_response.dart';
import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant.dart';
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

  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescCtrl = TextEditingController();
  TextEditingController productQntCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productOffPriceCtrl = TextEditingController();

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

  bool useVariants = false;
  List<VariantFormData> variantForms = [];
  List<VariantOptionFormData> variantOptions = [];
  TextEditingController bulkPriceCtrl = TextEditingController();
  TextEditingController bulkOfferPriceCtrl = TextEditingController();
  TextEditingController bulkQtyCtrl = TextEditingController();

  DashBoardProvider(this._dataProvider);

  @override
  void dispose() {
    productNameCtrl.dispose();
    productDescCtrl.dispose();
    productQntCtrl.dispose();
    productPriceCtrl.dispose();
    productOffPriceCtrl.dispose();
    bulkPriceCtrl.dispose();
    bulkOfferPriceCtrl.dispose();
    bulkQtyCtrl.dispose();
    for (final variant in variantForms) {
      variant.dispose();
    }
    super.dispose();
  }

  void setVariantMode(bool enabled) {
    useVariants = enabled;
    if (enabled && variantForms.isEmpty) {
      if (variantOptions.isEmpty) {
        addVariantOption();
      }
    }
    notifyListeners();
  }

  void addVariantOption() {
    variantOptions.add(VariantOptionFormData());
    notifyListeners();
  }

  void removeVariantOption(int optionIndex) {
    if (optionIndex < 0 || optionIndex >= variantOptions.length) return;
    final removed = variantOptions.removeAt(optionIndex);
    removed.dispose();
    notifyListeners();
  }

  void updateVariantOptionType(int optionIndex, VariantType? variantType) {
    if (optionIndex < 0 || optionIndex >= variantOptions.length) return;
    final option = variantOptions[optionIndex];
    option.selectedType = variantType;
    option.selectedValues = [];
    notifyListeners();
  }

  void updateVariantOptionValues(int optionIndex, List<Variant> values) {
    if (optionIndex < 0 || optionIndex >= variantOptions.length) return;
    variantOptions[optionIndex].selectedValues = List<Variant>.from(values);
    notifyListeners();
  }

  String? generateVariantsFromOptions() {
    if (variantOptions.isEmpty) {
      return 'Please add at least one option.';
    }

    for (int i = 0; i < variantOptions.length; i++) {
      final option = variantOptions[i];
      if (option.selectedType == null) {
        return 'Option #${i + 1}: please select variant type.';
      }
      if (option.selectedValues.isEmpty) {
        return 'Option #${i + 1}: please select at least one value.';
      }
    }

    final currentByKey = <String, VariantFormData>{};
    for (final variant in variantForms) {
      final key = _buildAttributeFormKey(variant.attributes);
      currentByKey[key] = variant;
    }

    final generatedAttributes = _cartesianVariantAttributes(variantOptions);
    final nextVariantForms = <VariantFormData>[];

    for (final attrs in generatedAttributes) {
      final key = _buildAttributeFormKey(attrs);
      final existing = currentByKey[key];
      if (existing != null) {
        nextVariantForms.add(existing);
      } else {
        nextVariantForms.add(
          VariantFormData(
            skuCtrl: TextEditingController(text: _buildGeneratedSku(attrs)),
            priceCtrl: TextEditingController(text: ''),
            offerPriceCtrl: TextEditingController(text: ''),
            quantityCtrl: TextEditingController(text: ''),
            attributes: attrs,
            images: [VariantImageFormData()],
            isActive: true,
          ),
        );
      }
    }

    for (final old in variantForms) {
      if (!nextVariantForms.contains(old)) {
        old.dispose();
      }
    }

    variantForms = nextVariantForms;
    notifyListeners();
    return null;
  }

  List<List<AttributeFormData>> _cartesianVariantAttributes(
      List<VariantOptionFormData> options) {
    List<List<AttributeFormData>> result = [[]];

    for (final option in options) {
      final current = <List<AttributeFormData>>[];
      for (final base in result) {
        for (final value in option.selectedValues) {
          current.add([
            ...base.map((item) => AttributeFormData(
                  selectedVariantType: item.selectedVariantType,
                  selectedVariant: item.selectedVariant,
                )),
            AttributeFormData(
              selectedVariantType: option.selectedType,
              selectedVariant: value,
            ),
          ]);
        }
      }
      result = current;
    }
    return result;
  }

  String _buildGeneratedSku(List<AttributeFormData> attributes) {
    final parts = attributes
        .map((item) => (item.selectedVariant?.name ?? '').trim().toUpperCase())
        .where((text) => text.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    return parts.join('-').replaceAll(' ', '');
  }

  String _buildAttributeFormKey(List<AttributeFormData> attributes) {
    final entries = attributes
        .map((item) {
          final typeId = item.selectedVariantType?.sId ?? '';
          final variantId = item.selectedVariant?.sId ?? '';
          return '$typeId:$variantId';
        })
        .where((entry) => entry != ':')
        .toList()
      ..sort((a, b) => a.compareTo(b));
    return entries.join('|');
  }

  void applyBulkToAllVariants() {
    final price = bulkPriceCtrl.text.trim();
    final offer = bulkOfferPriceCtrl.text.trim();
    final qty = bulkQtyCtrl.text.trim();

    for (final variant in variantForms) {
      if (price.isNotEmpty) variant.priceCtrl.text = price;
      if (offer.isNotEmpty) variant.offerPriceCtrl.text = offer;
      if (qty.isNotEmpty) variant.quantityCtrl.text = qty;
    }
    notifyListeners();
  }

  void addVariantForm({ProductVariant? initialVariant}) {
    variantForms.add(VariantFormData.fromProductVariant(initialVariant));
    notifyListeners();
  }

  void removeVariantForm(int variantIndex) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    final removed = variantForms.removeAt(variantIndex);
    removed.dispose();
    notifyListeners();
  }

  void addAttributeField(int variantIndex) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    variantForms[variantIndex].attributes.add(AttributeFormData());
    notifyListeners();
  }

  void removeAttributeField(int variantIndex, int attributeIndex) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    final attributes = variantForms[variantIndex].attributes;
    if (attributeIndex < 0 || attributeIndex >= attributes.length) return;
    final removed = attributes.removeAt(attributeIndex);
    removed.dispose();
    if (attributes.isEmpty) {
      attributes.add(AttributeFormData());
    }
    notifyListeners();
  }

  void addVariantImageField(int variantIndex) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    if (variantForms[variantIndex].images.length >= 3) {
      SnackBarHelper.showErrorSnackBar('Each variant can have up to 3 images.');
      return;
    }
    variantForms[variantIndex].images.add(VariantImageFormData());
    notifyListeners();
  }

  void removeVariantImageField(int variantIndex, int imageIndex) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    final images = variantForms[variantIndex].images;
    if (imageIndex < 0 || imageIndex >= images.length) return;
    final removed = images.removeAt(imageIndex);
    removed.dispose();
    if (images.isEmpty) {
      images.add(VariantImageFormData());
    }
    notifyListeners();
  }

  Future<void> pickVariantImage({
    required int variantIndex,
    required int imageIndex,
  }) async {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    final variantImages = variantForms[variantIndex].images;
    if (imageIndex < 0 || imageIndex >= variantImages.length) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    variantImages[imageIndex].selectedXFile = image;
    variantImages[imageIndex].previewUrl = image.path;
    if (!kIsWeb) {
      variantImages[imageIndex].selectedFile = File(image.path);
    }
    notifyListeners();
  }

  void updateVariantActive(int variantIndex, bool isActive) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    variantForms[variantIndex].isActive = isActive;
    notifyListeners();
  }

  void updateAttributeVariantType(
    int variantIndex,
    int attributeIndex,
    VariantType? variantType,
  ) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    final attributes = variantForms[variantIndex].attributes;
    if (attributeIndex < 0 || attributeIndex >= attributes.length) return;

    final attribute = attributes[attributeIndex];
    attribute.selectedVariantType = variantType;
    attribute.selectedVariant = null;
    notifyListeners();
  }

  void updateAttributeVariant(
    int variantIndex,
    int attributeIndex,
    Variant? variant,
  ) {
    if (variantIndex < 0 || variantIndex >= variantForms.length) return;
    final attributes = variantForms[variantIndex].attributes;
    if (attributeIndex < 0 || attributeIndex >= attributes.length) return;

    attributes[attributeIndex].selectedVariant = variant;
    notifyListeners();
  }

  List<Variant> variantsByType(String? variantTypeId) {
    if (variantTypeId == null || variantTypeId.isEmpty) return [];
    return _dataProvider.variants
        .where((variant) => variant.variantTypeId?.sId == variantTypeId)
        .toList();
  }

  Future<bool> addProduct() async {
    try {
      if (mainImgXFile == null) {
        SnackBarHelper.showErrorSnackBar('Please Choose A Image !');
        return false;
      }

      final variantError = validateVariantBusinessRules();
      if (variantError != null) {
        SnackBarHelper.showErrorSnackBar(variantError);
        return false;
      }

      SnackBarHelper.showLoadingSnackBar(
          'Adding product and uploading images...');

      final built = useVariants
          ? _buildVariantPayloadAndFiles()
          : VariantBuildResult(variants: [], files: {});
      final fallbackStock = _buildFallbackStockForProduct(built.variants);

      final Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text.trim(),
        'description': productDescCtrl.text.trim(),
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'price': fallbackStock.price,
        'offerPrice': fallbackStock.offerPrice,
        'quantity': fallbackStock.quantity,
        'variants': jsonEncode(built.variants),
      };

      if (selectedBrand?.sId != null && selectedBrand!.sId!.isNotEmpty) {
        formDataMap['proBrandId'] = selectedBrand?.sId;
      }

      final form = await createFormDataForMultipleImage(
        fileFields: {
          'image1': mainImgXFile,
          'image2': secondImgXFile,
          'image3': thirdImgXFile,
          'image4': fourthImgXFile,
          'image5': fifthImgXFile,
          ...built.files,
        },
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
        SnackBarHelper.showErrorSnackBar(
            response.body?['message'] ?? 'Request failed.');
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

      final variantError = validateVariantBusinessRules();
      if (variantError != null) {
        SnackBarHelper.showErrorSnackBar(variantError);
        return false;
      }

      SnackBarHelper.showLoadingSnackBar('Updating product details...');

      final built = useVariants
          ? _buildVariantPayloadAndFiles()
          : VariantBuildResult(variants: [], files: {});
      final fallbackStock = _buildFallbackStockForProduct(built.variants);

      final Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text.trim(),
        'description': productDescCtrl.text.trim(),
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'price': fallbackStock.price,
        'offerPrice': fallbackStock.offerPrice,
        'quantity': fallbackStock.quantity,
        'variants': jsonEncode(built.variants),
      };

      if (selectedBrand?.sId != null && selectedBrand!.sId!.isNotEmpty) {
        formDataMap['proBrandId'] = selectedBrand?.sId;
      } else {
        formDataMap['proBrandId'] = null;
      }

      final form = await createFormDataForMultipleImage(
        fileFields: {
          'image1': mainImgXFile,
          'image2': secondImgXFile,
          'image3': thirdImgXFile,
          'image4': fourthImgXFile,
          'image5': fifthImgXFile,
          ...built.files,
        },
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
        SnackBarHelper.showErrorSnackBar(
            response.body?['message'] ?? 'Update failed.');
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
      Response response = await service.deleteItem(
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
        SnackBarHelper.showErrorSnackBar(
            response.body?['message'] ?? 'Delete failed.');
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
    required Map<String, XFile?> fileFields,
    required Map<String, dynamic> formData,
  }) async {
    for (final entry in fileFields.entries) {
      final field = entry.key;
      final imgXFile = entry.value;
      if (imgXFile == null) continue;

      if (kIsWeb) {
        final fileName = imgXFile.name;
        final byteImg = await imgXFile.readAsBytes();
        formData[field] = MultipartFile(byteImg, filename: fileName);
      } else {
        final filePath = imgXFile.path;
        final fileName = filePath.split('/').last;
        formData[field] = await MultipartFile(filePath, filename: fileName);
      }
    }
    return FormData(formData);
  }

  void filterSubCategory(Category category) {
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

  void filterBrand(SubCategory subCategory) {
    selectedBrand = null;
    brandsBySubCategory.clear();
    selectedSubCategory = subCategory;
    final newListBrand = _dataProvider.brands
        .where((brand) => brand.subCategoryId?.sId == subCategory.sId)
        .toList();
    brandsBySubCategory = newListBrand;
    notifyListeners();
  }

  void filterVariant(VariantType variantType) {
    selectedVariants = [];
    selectedVariantType = variantType;
    final newListVariant = _dataProvider.variants
        .where((variant) => variant.variantTypeId?.sId == variantType.sId)
        .toList();
    final variantNames =
        newListVariant.map((variant) => variant.name ?? '').toList();
    variantsByVariantType = variantNames;
    notifyListeners();
  }

  void setDataForUpdateProduct(Product? product) {
    if (product != null) {
      productForUpdate = product;

      productNameCtrl.text = product.name ?? '';
      productDescCtrl.text = product.description ?? '';
      productPriceCtrl.text = (product.price ?? '').toString();
      productOffPriceCtrl.text =
          product.offerPrice != null ? '${product.offerPrice}' : '';
      productQntCtrl.text = '${product.quantity ?? ''}';

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
      selectedBrand = _dataProvider.brands
          .firstWhereOrNull((element) => element.sId == product.proBrandId?.sId);

      final productVariants = product.variants ?? [];
      for (final variant in variantForms) {
        variant.dispose();
      }
      variantForms.clear();

      if (productVariants.isNotEmpty) {
        useVariants = true;
        for (final variant in productVariants) {
          variantForms.add(
            VariantFormData.fromProductVariant(
              variant,
              attributesFromCatalog: _mapAttributesFromProduct(variant.attributes),
            ),
          );
        }
        variantOptions = _buildOptionsFromVariants(variantForms);
      } else {
        useVariants = false;
        variantOptions = [];
      }
    } else {
      clearFields();
    }
    notifyListeners();
  }

  void clearFields() {
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
    useVariants = false;
    bulkPriceCtrl.clear();
    bulkOfferPriceCtrl.clear();
    bulkQtyCtrl.clear();

    for (final variant in variantForms) {
      variant.dispose();
    }
    variantForms = [];
    for (final option in variantOptions) {
      option.dispose();
    }
    variantOptions = [];

    productForUpdate = null;

    subCategoriesByCategory = [];
    brandsBySubCategory = [];
    variantsByVariantType = [];

    notifyListeners();
  }

  String? validateVariantBusinessRules() {
    if (!useVariants) {
      return _validateLegacyPricingFields();
    }

    if (variantForms.isEmpty) {
      return 'Please add at least one variant.';
    }

    final skuSet = <String>{};
    final attributeCombinationSet = <String>{};

    for (int i = 0; i < variantForms.length; i++) {
      final variant = variantForms[i];
      final sku = variant.skuCtrl.text.trim();
      if (sku.isEmpty) {
        return 'Variant #${i + 1}: SKU is required.';
      }

      final normalizedSku = sku.toLowerCase();
      if (skuSet.contains(normalizedSku)) {
        return 'Duplicate SKU detected: $sku';
      }
      skuSet.add(normalizedSku);

      final price = _toPositiveOrZeroDouble(variant.priceCtrl.text.trim());
      if (price == null) {
        return 'Variant #${i + 1}: Price must be a valid number >= 0.';
      }

      final offerText = variant.offerPriceCtrl.text.trim();
      final offer = offerText.isEmpty ? null : _toPositiveOrZeroDouble(offerText);
      if (offerText.isNotEmpty && offer == null) {
        return 'Variant #${i + 1}: Offer price is invalid.';
      }
      if (offer != null && offer > price) {
        return 'Variant #${i + 1}: Offer price cannot be greater than price.';
      }

      final quantity = _toNonNegativeInt(variant.quantityCtrl.text.trim());
      if (quantity == null) {
        return 'Variant #${i + 1}: Quantity must be an integer >= 0.';
      }

      final selectedTypeIds = <String>{};
      for (final attributeRow in variant.attributes) {
        final hasType = attributeRow.selectedVariantType != null;
        final hasVariant = attributeRow.selectedVariant != null;
        if (hasType != hasVariant) {
          return 'Variant #${i + 1}: Please select both variant type and value.';
        }
        if (hasType) {
          final typeId = attributeRow.selectedVariantType?.sId ?? '';
          if (typeId.isNotEmpty && selectedTypeIds.contains(typeId)) {
            return 'Variant #${i + 1}: Duplicate variant type in attributes.';
          }
          if (typeId.isNotEmpty) {
            selectedTypeIds.add(typeId);
          }
        }
      }

      final attributes = _buildAttributes(variant.attributes);
      if (attributes.isEmpty) {
        return 'Variant #${i + 1}: Please add at least one attribute.';
      }

      final attributesKey = _buildAttributesUniqueKey(attributes);
      if (attributeCombinationSet.contains(attributesKey)) {
        return 'Duplicate attribute combination at variant #${i + 1}.';
      }
      attributeCombinationSet.add(attributesKey);

    }

    return null;
  }

  String? _validateLegacyPricingFields() {
    final price = _toPositiveOrZeroDouble(productPriceCtrl.text.trim());
    if (price == null) {
      return 'Please enter a valid product price.';
    }

    final quantity = _toNonNegativeInt(productQntCtrl.text.trim());
    if (quantity == null) {
      return 'Please enter a valid product quantity.';
    }

    final offerText = productOffPriceCtrl.text.trim();
    if (offerText.isNotEmpty) {
      final offer = _toPositiveOrZeroDouble(offerText);
      if (offer == null) {
        return 'Please enter a valid offer price.';
      }
      if (offer > price) {
        return 'Offer price cannot be greater than price.';
      }
    }

    return null;
  }

  VariantBuildResult _buildVariantPayloadAndFiles() {
    final variants = <Map<String, dynamic>>[];
    final files = <String, XFile>{};

    for (int variantIndex = 0; variantIndex < variantForms.length; variantIndex++) {
      final variant = variantForms[variantIndex];
      final images = <Map<String, dynamic>>[];

      for (int imageIndex = 0; imageIndex < variant.images.length; imageIndex++) {
        final image = variant.images[imageIndex];
        final existingUrl = (image.existingUrl ?? '').trim();
        if (existingUrl.isNotEmpty) {
          images.add({
            'image': imageIndex + 1,
            'url': existingUrl,
          });
          continue;
        }

        if (image.selectedXFile != null) {
          final fieldName = 'variantImage_${variantIndex + 1}_${imageIndex + 1}';
          files[fieldName] = image.selectedXFile!;
          images.add({
            'image': imageIndex + 1,
            'url': fieldName,
          });
        }
      }

      variants.add({
        if (variant.id != null && variant.id!.isNotEmpty) '_id': variant.id,
        'sku': variant.skuCtrl.text.trim(),
        'attributes': _buildAttributes(variant.attributes),
        'price': double.parse(variant.priceCtrl.text.trim()),
        'offerPrice': variant.offerPriceCtrl.text.trim().isEmpty
            ? null
            : double.parse(variant.offerPriceCtrl.text.trim()),
        'quantity': int.parse(variant.quantityCtrl.text.trim()),
        'images': images,
        'isActive': variant.isActive,
      });
    }

    return VariantBuildResult(variants: variants, files: files);
  }

  ProductFallbackStock _buildFallbackStockForProduct(
      List<Map<String, dynamic>> variants) {
    if (!useVariants) {
      return ProductFallbackStock(
        price: productPriceCtrl.text.trim(),
        offerPrice: productOffPriceCtrl.text.trim(),
        quantity: productQntCtrl.text.trim(),
      );
    }

    if (variants.isEmpty) {
      return ProductFallbackStock(price: '0', offerPrice: '', quantity: '0');
    }

    double minPrice = double.infinity;
    int totalQuantity = 0;

    for (final variant in variants) {
      final price = (variant['price'] as num).toDouble();
      final quantity = (variant['quantity'] as num).toInt();
      if (price < minPrice) {
        minPrice = price;
      }
      totalQuantity += quantity;
    }

    return ProductFallbackStock(
      price: minPrice.toString(),
      offerPrice: '',
      quantity: totalQuantity.toString(),
    );
  }

  List<Map<String, String>> _buildAttributes(
      List<AttributeFormData> attributes) {
    final result = <Map<String, String>>[];
    for (final attr in attributes) {
      final selectedType = attr.selectedVariantType;
      final selectedVariant = attr.selectedVariant;
      if (selectedType == null && selectedVariant == null) {
        continue;
      }
      if (selectedType != null && selectedVariant != null) {
        final typeId = selectedType.sId ?? '';
        final variantId = selectedVariant.sId ?? '';
        if (typeId.isNotEmpty && variantId.isNotEmpty) {
          result.add({
            'variantTypeId': typeId,
            'variantId': variantId,
          });
        }
      }
    }
    return result;
  }

  List<AttributeFormData> _mapAttributesFromProduct(
      List<ProductVariantAttribute> productAttributes) {
    final rows = <AttributeFormData>[];

    for (final entry in productAttributes) {
      final typeId = entry.variantType?.sId;
      final variantId = entry.variant?.sId;
      final type = _dataProvider.variantTypes
          .firstWhereOrNull((variantType) => variantType.sId == typeId);
      final variant =
          _dataProvider.variants.firstWhereOrNull((item) => item.sId == variantId);

      rows.add(
        AttributeFormData(
          selectedVariantType: type,
          selectedVariant: variant,
        ),
      );
    }

    if (rows.isEmpty) {
      rows.add(AttributeFormData());
    }
    return rows;
  }

  String _buildAttributesUniqueKey(List<Map<String, String>> attributes) {
    final entries = attributes
        .map((item) =>
            '${item['variantTypeId'] ?? ''}:${item['variantId'] ?? ''}')
        .toList()
      ..sort((a, b) => a.compareTo(b));
    return entries
        .join('|');
  }

  List<VariantOptionFormData> _buildOptionsFromVariants(
      List<VariantFormData> variants) {
    final map = <String, VariantOptionFormData>{};

    for (final variant in variants) {
      for (final attr in variant.attributes) {
        final type = attr.selectedVariantType;
        final value = attr.selectedVariant;
        if (type == null || value == null) continue;

        final key = type.sId ?? '';
        if (key.isEmpty) continue;

        final option = map.putIfAbsent(
          key,
          () => VariantOptionFormData(
            selectedType: type,
            selectedValues: [],
          ),
        );
        final exists =
            option.selectedValues.any((item) => item.sId == value.sId);
        if (!exists) {
          option.selectedValues.add(value);
        }
      }
    }

    return map.values.toList();
  }

  int? _toNonNegativeInt(String value) {
    if (value.isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  double? _toPositiveOrZeroDouble(String value) {
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  void updateUI() {
    notifyListeners();
  }
}

class ProductFallbackStock {
  final String price;
  final String offerPrice;
  final String quantity;

  ProductFallbackStock({
    required this.price,
    required this.offerPrice,
    required this.quantity,
  });
}

class VariantBuildResult {
  final List<Map<String, dynamic>> variants;
  final Map<String, XFile> files;

  VariantBuildResult({
    required this.variants,
    required this.files,
  });
}

class VariantOptionFormData {
  VariantType? selectedType;
  List<Variant> selectedValues;

  VariantOptionFormData({
    this.selectedType,
    List<Variant>? selectedValues,
  }) : selectedValues = selectedValues ?? [];

  void dispose() {
    // no-op
  }
}

class VariantFormData {
  final String? id;
  final TextEditingController skuCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController offerPriceCtrl;
  final TextEditingController quantityCtrl;
  final List<AttributeFormData> attributes;
  final List<VariantImageFormData> images;
  bool isActive;

  VariantFormData({
    this.id,
    required this.skuCtrl,
    required this.priceCtrl,
    required this.offerPriceCtrl,
    required this.quantityCtrl,
    required this.attributes,
    required this.images,
    this.isActive = true,
  });

  factory VariantFormData.fromProductVariant(
    ProductVariant? variant, {
    List<AttributeFormData>? attributesFromCatalog,
  }) {
    if (variant == null) {
      return VariantFormData(
        skuCtrl: TextEditingController(text: ''),
        priceCtrl: TextEditingController(text: ''),
        offerPriceCtrl: TextEditingController(text: ''),
        quantityCtrl: TextEditingController(text: ''),
        attributes: [AttributeFormData()],
        images: [VariantImageFormData()],
        isActive: true,
      );
    }

    final attributeRows = attributesFromCatalog ?? [AttributeFormData()];
    if (attributeRows.isEmpty) {
      attributeRows.add(AttributeFormData());
    }

    final variantImages =
        variant.images
            .map((image) => VariantImageFormData(existingUrl: image.url))
            .toList();
    if (variantImages.isEmpty) {
      variantImages.add(VariantImageFormData());
    }

    return VariantFormData(
      id: variant.sId,
      skuCtrl: TextEditingController(text: variant.sku),
      priceCtrl: TextEditingController(text: variant.price.toString()),
      offerPriceCtrl:
          TextEditingController(text: variant.offerPrice?.toString() ?? ''),
      quantityCtrl: TextEditingController(text: variant.quantity.toString()),
      attributes: attributeRows,
      images: variantImages,
      isActive: variant.isActive,
    );
  }

  void dispose() {
    skuCtrl.dispose();
    priceCtrl.dispose();
    offerPriceCtrl.dispose();
    quantityCtrl.dispose();
    for (final attr in attributes) {
      attr.dispose();
    }
    for (final image in images) {
      image.dispose();
    }
  }
}

class AttributeFormData {
  VariantType? selectedVariantType;
  Variant? selectedVariant;

  AttributeFormData({
    this.selectedVariantType,
    this.selectedVariant,
  });

  void dispose() {
    // no-op
  }
}

class VariantImageFormData {
  String? existingUrl;
  String? previewUrl;
  File? selectedFile;
  XFile? selectedXFile;

  VariantImageFormData({
    this.existingUrl,
    this.previewUrl,
    this.selectedFile,
    this.selectedXFile,
  });

  void dispose() {
    // no-op
  }
}
