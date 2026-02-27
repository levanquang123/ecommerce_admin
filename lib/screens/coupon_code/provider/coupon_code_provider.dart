import '../../../models/api_response.dart';
import '../../../models/coupon.dart';
import '../../../models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class CouponCodeProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  Coupon? couponForUpdate;

  final addCouponFormKey = GlobalKey<FormState>();
  TextEditingController couponCodeCtrl = TextEditingController();
  TextEditingController discountAmountCtrl = TextEditingController();
  TextEditingController minimumPurchaseAmountCtrl = TextEditingController();
  TextEditingController endDateCtrl = TextEditingController();
  String selectedDiscountType = 'fixed';
  String selectedCouponStatus = 'active';
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Product? selectedProduct;

  CouponCodeProvider(this._dataProvider);

  Future<bool> addCoupon() async {
    try {
      if (endDateCtrl.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Select end date');
        return false;
      }

      Map<String, dynamic> coupon = {
        "couponCode": couponCodeCtrl.text.trim(),
        "discountType": selectedDiscountType,
        "discountAmount": discountAmountCtrl.text,
        "minimumPurchaseAmount": minimumPurchaseAmountCtrl.text,
        "endDate": endDateCtrl.text,
        "status": selectedCouponStatus,
        "applicableCategory": selectedCategory?.sId,
        "applicableSubCategory": selectedSubCategory?.sId,
        "applicableProduct": selectedProduct?.sId,
      };

      final response = await service.addItem(
        endpointUrl: 'couponCodes',
        itemData: coupon,
      );

      if (response.isOk) {
        ApiResponse apiResponse =
        ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          _dataProvider.getAllCoupons();

          SnackBarHelper.showSuccessSnackBar(
            apiResponse.message ?? 'Coupon added successfully',
          );

          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
            apiResponse.message ?? 'Failed to add coupon',
          );
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? response.statusText,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Add coupon error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateCoupon() async {
    try {
      if (couponForUpdate == null || (couponForUpdate?.sId ?? '').isEmpty) {
        SnackBarHelper.showErrorSnackBar("Coupon not selected for update");
        return false;
      }

      if (endDateCtrl.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Select end date');
        return false;
      }

      final Map<String, dynamic> coupon = {
        "couponCode": couponCodeCtrl.text.trim(),
        "discountType": selectedDiscountType,
        "discountAmount": discountAmountCtrl.text,
        "minimumPurchaseAmount": minimumPurchaseAmountCtrl.text,
        "endDate": endDateCtrl.text,
        "status": selectedCouponStatus,
        "applicableCategory": selectedCategory?.sId,
        "applicableSubCategory": selectedSubCategory?.sId,
        "applicableProduct": selectedProduct?.sId,
      };

      final response = await service.updateItem(
        endpointUrl: "couponCodes",
        itemId: couponForUpdate?.sId ?? "",
        itemData: coupon,
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          _dataProvider.getAllCoupons();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message ?? "Updated");
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update coupon: ${apiResponse.message}",
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
      SnackBarHelper.showErrorSnackBar("Error: $e");
      return false;
    }
  }

  Future<bool> submitCoupon() async {
    if (couponForUpdate != null) {
      return await updateCoupon();
    } else {
      return await addCoupon();
    }
  }

  Future<void> deleteCoupon(Coupon coupon) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'couponCodes',
        itemId: coupon.sId ?? "",
      );

      if (response.isOk) {
        final apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Coupon Deleted Successfully');
          _dataProvider.getAllCoupons();
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message ?? 'Delete failed');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          response.body?['message'] ?? response.statusText ?? "Server Error",
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar("Error: $e");
    }
  }

  //? set data for update on editing
  setDataForUpdateCoupon(Coupon? coupon) {
    if (coupon != null) {
      couponForUpdate = coupon;
      couponCodeCtrl.text = coupon.couponCode ?? '';
      selectedDiscountType = coupon.discountType ?? 'fixed';
      discountAmountCtrl.text = '${coupon.discountAmount}';
      minimumPurchaseAmountCtrl.text = '${coupon.minimumPurchaseAmount}';
      endDateCtrl.text = '${coupon.endDate}';
      selectedCouponStatus = coupon.status ?? 'active';
      selectedCategory = _dataProvider.categories.firstWhereOrNull(
          (element) => element.sId == coupon.applicableCategory?.sId);
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == coupon.applicableSubCategory?.sId);
      selectedProduct = _dataProvider.products.firstWhereOrNull(
          (element) => element.sId == coupon.applicableProduct?.sId);
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update coupon
  clearFields() {
    couponForUpdate = null;
    selectedCategory = null;
    selectedSubCategory = null;
    selectedProduct = null;

    couponCodeCtrl.text = '';
    discountAmountCtrl.text = '';
    minimumPurchaseAmountCtrl.text = '';
    endDateCtrl.text = '';
  }

  updateUi() {
    notifyListeners();
  }
}
