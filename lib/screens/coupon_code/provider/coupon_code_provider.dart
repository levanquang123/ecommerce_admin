import '../../../models/coupon.dart';
import '../../../models/product.dart';
import '../data/coupon_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../utility/snack_bar_helper.dart';

class CouponCodeProvider extends ChangeNotifier {
  final CouponRepository _couponRepository;
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

  CouponCodeProvider(this._dataProvider, this._couponRepository);

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

      final apiResponse = await _couponRepository.createCoupon(coupon);

      if (apiResponse.success == true) {
        clearFields();
        _dataProvider.getAllCoupons();

        SnackBarHelper.showSuccessSnackBar(
          apiResponse.message,
        );

        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
          apiResponse.message,
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

      final apiResponse = await _couponRepository.updateCoupon(
        couponId: couponForUpdate?.sId ?? "",
        data: coupon,
      );

      if (apiResponse.success == true) {
        clearFields();
        _dataProvider.getAllCoupons();
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
          "Failed to update coupon: ${apiResponse.message}",
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
      final apiResponse = await _couponRepository.deleteCoupon(coupon);
      if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar('Coupon Deleted Successfully');
        _dataProvider.getAllCoupons();
      } else {
        SnackBarHelper.showErrorSnackBar(apiResponse.message);
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

  @override
  void dispose() {
    couponCodeCtrl.dispose();
    discountAmountCtrl.dispose();
    minimumPurchaseAmountCtrl.dispose();
    endDateCtrl.dispose();
    super.dispose();
  }
}
