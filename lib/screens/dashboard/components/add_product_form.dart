import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant.dart';
import '../../../models/variant_type.dart';
import '../provider/dash_board_provider.dart';
import '../../../utility/extensions.dart';
import '../../../utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/multi_select_drop_down.dart';
import '../../../widgets/product_image_card.dart';

class ProductSubmitForm extends StatefulWidget {
  final Product? product;

  const ProductSubmitForm({super.key, this.product});

  @override
  State<ProductSubmitForm> createState() => _ProductSubmitFormState();
}

class _ProductSubmitFormState extends State<ProductSubmitForm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashBoardProvider>().setDataForUpdateProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Form(
        key: context.dashBoardProvider.addProductFormKey,
        child: Container(
          width: size.width * 0.75,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Consumer<DashBoardProvider>(
            builder: (context, dashProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: defaultPadding),
                  _buildImageRow(dashProvider),
                  const SizedBox(height: defaultPadding),
                  CustomTextField(
                    controller: dashProvider.productNameCtrl,
                    labelText: 'Product Name',
                    onSave: (val) {},
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  CustomTextField(
                    controller: dashProvider.productDescCtrl,
                    labelText: 'Product Description',
                    lineNumber: 3,
                    onSave: (val) {},
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown(
                          key: ValueKey(dashProvider.selectedCategory?.sId),
                          initialValue: dashProvider.selectedCategory,
                          hintText:
                              dashProvider.selectedCategory?.name ?? 'Select category',
                          items: context.dataProvider.categories,
                          displayItem: (Category? category) => category?.name ?? '',
                          onChanged: (newValue) {
                            if (newValue != null) {
                              dashProvider.filterSubCategory(newValue);
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomDropdown(
                          key: ValueKey(dashProvider.selectedSubCategory?.sId),
                          hintText:
                              dashProvider.selectedSubCategory?.name ?? 'Sub category',
                          items: dashProvider.subCategoriesByCategory,
                          initialValue: dashProvider.selectedSubCategory,
                          displayItem: (SubCategory? subCategory) =>
                              subCategory?.name ?? '',
                          onChanged: (newValue) {
                            if (newValue != null) {
                              dashProvider.filterBrand(newValue);
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select sub category';
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomDropdown(
                          key: ValueKey(dashProvider.selectedBrand?.sId),
                          initialValue: dashProvider.selectedBrand,
                          items: dashProvider.brandsBySubCategory,
                          hintText: dashProvider.selectedBrand?.name ?? 'Select Brand',
                          displayItem: (Brand? brand) => brand?.name ?? '',
                          onChanged: (newValue) {
                            dashProvider.selectedBrand = newValue;
                            dashProvider.updateUI();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  SwitchListTile.adaptive(
                    value: dashProvider.useVariants,
                    title: const Text('This product has variants'),
                    subtitle: Text(
                      dashProvider.useVariants
                          ? 'Stock and pricing will be managed at variant level.'
                          : 'Using legacy product-level price and stock.',
                    ),
                    onChanged: (value) {
                      dashProvider.setVariantMode(value);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  if (!dashProvider.useVariants) _buildLegacyPriceFields(dashProvider),
                  if (dashProvider.useVariants) _buildVariantsSection(dashProvider),
                  const SizedBox(height: defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: secondaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: defaultPadding),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () async {
                          final formState =
                              context.dashBoardProvider.addProductFormKey.currentState;

                          if (formState == null) return;
                          if (!formState.validate()) return;

                          final validationError =
                              context.dashBoardProvider.validateVariantBusinessRules();
                          if (validationError != null) {
                            SnackBarHelper.showErrorSnackBar(validationError);
                            return;
                          }

                          formState.save();
                          final success =
                              await context.dashBoardProvider.submitProduct();
                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageRow(DashBoardProvider dashProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ProductImageCard(
          labelText: 'Main Image',
          imageFile: dashProvider.selectedMainImage,
          imageUrlForUpdateImage: widget.product?.images.safeElementAt(0)?.url,
          onTap: () => dashProvider.pickImage(imageCardNumber: 1),
          onRemoveImage: () {
            dashProvider.selectedMainImage = null;
            dashProvider.mainImgXFile = null;
            dashProvider.updateUI();
          },
        ),
        ProductImageCard(
          labelText: 'Second image',
          imageFile: dashProvider.selectedSecondImage,
          imageUrlForUpdateImage: widget.product?.images.safeElementAt(1)?.url,
          onTap: () => dashProvider.pickImage(imageCardNumber: 2),
          onRemoveImage: () {
            dashProvider.selectedSecondImage = null;
            dashProvider.secondImgXFile = null;
            dashProvider.updateUI();
          },
        ),
        ProductImageCard(
          labelText: 'Third image',
          imageFile: dashProvider.selectedThirdImage,
          imageUrlForUpdateImage: widget.product?.images.safeElementAt(2)?.url,
          onTap: () => dashProvider.pickImage(imageCardNumber: 3),
          onRemoveImage: () {
            dashProvider.selectedThirdImage = null;
            dashProvider.thirdImgXFile = null;
            dashProvider.updateUI();
          },
        ),
        ProductImageCard(
          labelText: 'Fourth image',
          imageFile: dashProvider.selectedFourthImage,
          imageUrlForUpdateImage: widget.product?.images.safeElementAt(3)?.url,
          onTap: () => dashProvider.pickImage(imageCardNumber: 4),
          onRemoveImage: () {
            dashProvider.selectedFourthImage = null;
            dashProvider.fourthImgXFile = null;
            dashProvider.updateUI();
          },
        ),
        ProductImageCard(
          labelText: 'Fifth image',
          imageFile: dashProvider.selectedFifthImage,
          imageUrlForUpdateImage: widget.product?.images.safeElementAt(4)?.url,
          onTap: () => dashProvider.pickImage(imageCardNumber: 5),
          onRemoveImage: () {
            dashProvider.selectedFifthImage = null;
            dashProvider.fifthImgXFile = null;
            dashProvider.updateUI();
          },
        ),
      ],
    );
  }

  Widget _buildLegacyPriceFields(DashBoardProvider dashProvider) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: dashProvider.productPriceCtrl,
            labelText: 'Price',
            inputType: TextInputType.number,
            onSave: (val) {},
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value.trim()) == null) {
                return 'Invalid price';
              }
              return null;
            },
          ),
        ),
        Expanded(
          child: CustomTextField(
            controller: dashProvider.productOffPriceCtrl,
            labelText: 'Offer price',
            inputType: TextInputType.number,
            onSave: (val) {},
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final parsedOffer = double.tryParse(value.trim());
              final parsedPrice =
                  double.tryParse(dashProvider.productPriceCtrl.text.trim());
              if (parsedOffer == null) {
                return 'Invalid offer price';
              }
              if (parsedPrice != null && parsedOffer > parsedPrice) {
                return 'Offer > Price';
              }
              return null;
            },
          ),
        ),
        Expanded(
          child: CustomTextField(
            controller: dashProvider.productQntCtrl,
            labelText: 'Quantity',
            inputType: TextInputType.number,
            onSave: (val) {},
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter quantity';
              }
              if (int.tryParse(value.trim()) == null) {
                return 'Quantity must be integer';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsSection(DashBoardProvider dashProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVariantOptionsSection(dashProvider),
          const SizedBox(height: defaultPadding),
          _buildVariantCombinationsSection(dashProvider),
        ],
      ),
    );
  }

  Widget _buildVariantOptionsSection(DashBoardProvider dashProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Variant Options',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: dashProvider.addVariantOption,
              icon: const Icon(Icons.add),
              label: const Text('Add option'),
            ),
          ],
        ),
        if (dashProvider.variantOptions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No option yet. Add at least one option.'),
          ),
        ...List.generate(dashProvider.variantOptions.length, (index) {
          final option = dashProvider.variantOptions[index];
          final values = option.selectedType == null
              ? <Variant>[]
              : dashProvider.variantsByType(option.selectedType?.sId);
          return Card(
            color: secondaryColor,
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDropdown<VariantType>(
                      key: ValueKey('option-type-$index-${option.selectedType?.sId}'),
                      initialValue: option.selectedType,
                      items: context.dataProvider.variantTypes,
                      hintText: 'Option Type',
                      displayItem: (item) => item.type ?? item.name ?? '',
                      onChanged: (newValue) =>
                          dashProvider.updateVariantOptionType(index, newValue),
                    ),
                  ),
                  Expanded(
                    child: MultiSelectDropDown<Variant>(
                      items: values,
                      selectedItems: option.selectedValues,
                      displayItem: (item) => item.name ?? '',
                      onSelectionChanged: (selected) =>
                          dashProvider.updateVariantOptionValues(index, selected),
                    ),
                  ),
                  IconButton(
                    onPressed: () => dashProvider.removeVariantOption(index),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ],
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              final error = dashProvider.generateVariantsFromOptions();
              if (error != null) {
                SnackBarHelper.showErrorSnackBar(error);
                return;
              }
              SnackBarHelper.showSuccessSnackBar('Variants generated.');
            },
            child: const Text('Generate Variants'),
          ),
        ),
      ],
    );
  }

  Widget _buildVariantCombinationsSection(DashBoardProvider dashProvider) {
    final total = dashProvider.variantForms.length;
    final active = dashProvider.variantForms.where((item) => item.isActive).length;
    final outOfStock = dashProvider.variantForms
        .where((item) => (int.tryParse(item.quantityCtrl.text.trim()) ?? 0) <= 0)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          '$total variants generated | $active active | $outOfStock out of stock',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 10),
        const Text(
          'Apply to all variants',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: dashProvider.bulkPriceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: dashProvider.bulkOfferPriceCtrl,
                decoration: const InputDecoration(labelText: 'Offer'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: dashProvider.bulkQtyCtrl,
                decoration: const InputDecoration(labelText: 'Qty'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: dashProvider.applyBulkToAllVariants,
              child: const Text('Apply'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (dashProvider.variantForms.isEmpty)
          const Text('No combinations yet. Generate variants first.')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Variant')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Offer')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Image')),
                DataColumn(label: Text('Active')),
                DataColumn(label: Text('Action')),
              ],
              rows: List.generate(dashProvider.variantForms.length, (index) {
                final variant = dashProvider.variantForms[index];
                final isExistingVariant =
                    dashProvider.productForUpdate != null &&
                        (variant.id?.isNotEmpty ?? false);
                final label = variant.attributes
                    .map((item) => item.selectedVariant?.name ?? '-')
                    .join(' / ');

                return DataRow(
                  cells: [
                    DataCell(Text(label)),
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: TextFormField(
                          controller: variant.skuCtrl,
                          enabled: !isExistingVariant,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: variant.priceCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: variant.offerPriceCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: variant.quantityCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    DataCell(
                      TextButton(
                        onPressed: () => _showVariantImageDialog(
                          context,
                          index,
                        ),
                        child: Text(
                          variant.images
                                  .where((img) =>
                                      (img.existingUrl ?? '').isNotEmpty ||
                                      (img.previewUrl ?? '').isNotEmpty ||
                                      img.selectedXFile != null)
                                  .length
                                  .toString() +
                              ' images',
                        ),
                      ),
                    ),
                    DataCell(
                      Switch(
                        value: variant.isActive,
                        onChanged: (value) =>
                            dashProvider.updateVariantActive(index, value),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          if (isExistingVariant)
                            ElevatedButton(
                              onPressed: () {
                                SnackBarHelper.showSuccessSnackBar(
                                  'Variant #${index + 1} updated in form.',
                                );
                              },
                              child: const Text('Update'),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }

  void _showVariantImageDialog(
    BuildContext context,
    int variantIndex,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return Consumer<DashBoardProvider>(
          builder: (context, provider, child) {
            if (variantIndex >= provider.variantForms.length) {
              return const SizedBox.shrink();
            }
            final variant = provider.variantForms[variantIndex];
            final canAddMore = variant.images.length < 3;

            return AlertDialog(
              backgroundColor: bgColor,
              title: Text('Variant #${variantIndex + 1} images'),
              content: SizedBox(
                width: 720,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: canAddMore
                            ? () => provider.addVariantImageField(variantIndex)
                            : null,
                        icon: const Icon(Icons.add),
                        label: Text(canAddMore
                            ? 'Add image'
                            : 'Max 3 images reached'),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(variant.images.length, (imageIndex) {
                        final image = variant.images[imageIndex];
                        return SizedBox(
                          width: 170,
                          child: ProductImageCard(
                            labelText: 'Image #${imageIndex + 1}',
                        imageFile: image.selectedFile,
                        imageUrlForUpdateImage:
                            image.previewUrl ?? image.existingUrl,
                            onTap: () => provider.pickVariantImage(
                              variantIndex: variantIndex,
                              imageIndex: imageIndex,
                            ),
                            onRemoveImage: () => provider.removeVariantImageField(
                              variantIndex,
                              imageIndex,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void showAddProductForm(BuildContext context, Product? product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text(
            'Add Product'.toUpperCase(),
            style: const TextStyle(color: primaryColor),
          ),
        ),
        content: ProductSubmitForm(product: product),
      );
    },
  );
}

extension SafeList<T> on List<T>? {
  T? safeElementAt(int index) {
    if (this == null || index < 0 || index >= this!.length) {
      return null;
    }
    return this![index];
  }
}
