import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/product.dart';
import '../../../models/variant.dart';
import '../../../models/variant_type.dart';

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

    final variantImages = variant.images
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
