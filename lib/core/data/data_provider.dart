import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/category.dart';
import '../../models/api_response.dart';
import '../../models/brand.dart';
import '../../models/coupon.dart';
import '../../models/my_notification.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/sub_category.dart';
import '../../models/variant.dart';
import '../../models/variant_type.dart';
import '../../utility/snack_bar_helper.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import 'data_list_state.dart';

class DataProvider extends ChangeNotifier {
  final ApiClient service;

  final DataListState<Category> _categories = DataListState<Category>();
  final DataListState<SubCategory> _subCategories =
      DataListState<SubCategory>();
  final DataListState<Brand> _brands = DataListState<Brand>();
  final DataListState<VariantType> _variantTypes =
      DataListState<VariantType>();
  final DataListState<Variant> _variants = DataListState<Variant>();
  final DataListState<Product> _products = DataListState<Product>();
  final DataListState<Coupon> _coupons = DataListState<Coupon>();
  final DataListState<Poster> _posters = DataListState<Poster>();
  final DataListState<Order> _orders = DataListState<Order>();
  final DataListState<MyNotification> _notifications =
      DataListState<MyNotification>();

  DataProvider(this.service);

  bool isLoading = false;

  List<Category> get categories => _categories.filtered;
  List<SubCategory> get subCategories => _subCategories.filtered;
  List<Brand> get brands => _brands.filtered;
  List<VariantType> get variantTypes => _variantTypes.filtered;
  List<Variant> get variants => _variants.filtered;
  List<Product> get products => _products.filtered;
  List<Coupon> get coupons => _coupons.filtered;
  List<Poster> get posters => _posters.filtered;
  List<Order> get orders => _orders.filtered;
  List<MyNotification> get notifications => _notifications.filtered;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await Future.wait([
      getAllCategory(),
      getAllBrands(),
      getAllProducts(),
      getAllVariant(),
      getAllVariantTypes(),
      getAllSubCategory(),
      getAllPosters(),
      getAllCoupons(),
      getAllOrders(),
      getAllNotifications(),
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    return _loadList<Category>(
      endpointUrl: ApiEndpoints.categories,
      state: _categories,
      fromJson: Category.fromJson,
      showSnack: showSnack,
    );
  }

  void filterCategories(String keyWord) {
    _filterByKeyword<Category>(
      state: _categories,
      keyWord: keyWord,
      matches: (category, lowerKeyWord) =>
          (category.name ?? '').toLowerCase().contains(lowerKeyWord),
    );
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    return _loadList<SubCategory>(
      endpointUrl: ApiEndpoints.subCategories,
      state: _subCategories,
      fromJson: SubCategory.fromJson,
      showSnack: showSnack,
    );
  }

  void filterSubCategories(String keyWord) {
    _filterByKeyword<SubCategory>(
      state: _subCategories,
      keyWord: keyWord,
      matches: (subCategory, lowerKeyWord) =>
          (subCategory.name ?? '').toLowerCase().contains(lowerKeyWord),
    );
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    return _loadList<Brand>(
      endpointUrl: ApiEndpoints.brands,
      state: _brands,
      fromJson: Brand.fromJson,
      showSnack: showSnack,
    );
  }

  void filterBrands(String keyWord) {
    _filterByKeyword<Brand>(
      state: _brands,
      keyWord: keyWord,
      matches: (brand, lowerKeyWord) =>
          (brand.name ?? '').toLowerCase().contains(lowerKeyWord),
    );
  }

  Future<List<VariantType>> getAllVariantTypes({bool showSnack = false}) async {
    return _loadList<VariantType>(
      endpointUrl: ApiEndpoints.variantTypes,
      state: _variantTypes,
      fromJson: VariantType.fromJson,
      showSnack: showSnack,
    );
  }

  void filterVariantTypes(String keyWord) {
    _filterByKeyword<VariantType>(
      state: _variantTypes,
      keyWord: keyWord,
      matches: (variantType, lowerKeyWord) {
        final name = (variantType.name ?? '').toLowerCase();
        final type = (variantType.type ?? '').toLowerCase();
        return name.contains(lowerKeyWord) || type.contains(lowerKeyWord);
      },
    );
  }

  Future<List<Variant>> getAllVariant({bool showSnack = false}) async {
    return _loadList<Variant>(
      endpointUrl: ApiEndpoints.variants,
      state: _variants,
      fromJson: Variant.fromJson,
      showSnack: showSnack,
    );
  }

  void filterVariant(String keyWord) {
    _filterByKeyword<Variant>(
      state: _variants,
      keyWord: keyWord,
      matches: (variant, lowerKeyWord) {
        final name = (variant.name ?? '').toLowerCase();
        final typeName = (variant.variantTypeId?.name ?? '').toLowerCase();
        return name.contains(lowerKeyWord) || typeName.contains(lowerKeyWord);
      },
    );
  }

  Future<List<Product>> getAllProducts({bool showSnack = false}) async {
    return _loadList<Product>(
      endpointUrl: ApiEndpoints.products,
      state: _products,
      fromJson: Product.fromJson,
      showSnack: showSnack,
    );
  }

  void filterProducts(String keyword) {
    _filterByKeyword<Product>(
      state: _products,
      keyWord: keyword,
      matches: (product, lowerKeyword) {
        final name = (product.name ?? '').toLowerCase();
        final category = (product.proCategoryId?.name ?? '').toLowerCase();
        final brand = (product.proBrandId?.name ?? '').toLowerCase();
        return name.contains(lowerKeyword) ||
            category.contains(lowerKeyword) ||
            brand.contains(lowerKeyword);
      },
    );
  }

  Future<List<Coupon>> getAllCoupons({bool showSnack = false}) async {
    return _loadList<Coupon>(
      endpointUrl: ApiEndpoints.couponCodes,
      state: _coupons,
      fromJson: Coupon.fromJson,
      showSnack: showSnack,
    );
  }

  void filterCoupons(String keyWord) {
    _filterByKeyword<Coupon>(
      state: _coupons,
      keyWord: keyWord,
      matches: (coupon, lowerKeyWord) =>
          (coupon.couponCode ?? '').toLowerCase().contains(lowerKeyWord),
    );
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    return _loadList<Poster>(
      endpointUrl: ApiEndpoints.posters,
      state: _posters,
      fromJson: Poster.fromJson,
      showSnack: showSnack,
    );
  }

  void filterPosters(String keyWord) {
    _filterByKeyword<Poster>(
      state: _posters,
      keyWord: keyWord,
      matches: (poster, lowerKeyWord) =>
          (poster.posterName ?? '').toLowerCase().contains(lowerKeyWord),
    );
  }

  Future<List<MyNotification>> getAllNotifications({bool showSnack = false}) {
    return _loadList<MyNotification>(
      endpointUrl: ApiEndpoints.notifications,
      state: _notifications,
      fromJson: MyNotification.fromJson,
      showSnack: showSnack,
    );
  }

  void filterNotifications(String keyword) {
    _filterByKeyword<MyNotification>(
      state: _notifications,
      keyWord: keyword,
      matches: (notification, lowerKeyword) =>
          (notification.title ?? '').toLowerCase().contains(lowerKeyword),
    );
  }

  Future<List<Order>> getAllOrders({bool showSnack = false}) async {
    return _loadList<Order>(
      endpointUrl: ApiEndpoints.orders,
      state: _orders,
      fromJson: Order.fromJson,
      showSnack: showSnack,
    );
  }

  void filterOrders(String keyword) {
    _filterByKeyword<Order>(
      state: _orders,
      keyWord: keyword,
      matches: (order, lowerKeyword) {
        final email = (order.userID?.email ?? '').toLowerCase();
        final status = (order.orderStatus ?? '').toLowerCase();
        return email.contains(lowerKeyword) || status.contains(lowerKeyword);
      },
    );
  }

  int calculateOrdersWithStatus({String? status}) {
    if (status == null) return _orders.all.length;
    return _orders.all.where((order) => order.orderStatus == status).length;
  }

  void filterProductsByQuantity(String productQntType) {
    if (productQntType == 'All Product') {
      _products.resetFilter();
    } else if (productQntType == 'Out of Stock') {
      _products.filter((product) => product.quantity != null && product.quantity == 0);
    } else if (productQntType == 'Limited Stock') {
      _products.filter((product) => product.quantity != null && product.quantity == 1);
    } else if (productQntType == 'Other Stock') {
      _products.filter((product) {
        return product.quantity != null &&
            product.quantity != 0 &&
            product.quantity != 1;
      });
    }
    notifyListeners();
  }

  int calculateProductWithQuantity({int? quantity}) {
    if (quantity == null) return _products.all.length;
    return _products.all.where((product) => product.quantity == quantity).length;
  }

  Future<List<T>> _loadList<T>({
    required String endpointUrl,
    required DataListState<T> state,
    required T Function(Map<String, dynamic> json) fromJson,
    required bool showSnack,
  }) async {
    try {
      final response = await service.getItems(endpointUrl: endpointUrl);
      if (response.isOk && response.body is Map) {
        final body = (response.body as Map).cast<String, dynamic>();
        final apiResponse = ApiResponse<List<T>>.fromJson(
          body,
          (json) => (json as List)
              .map((item) => fromJson((item as Map).cast<String, dynamic>()))
              .toList(),
        );
        state.setItems(apiResponse.data ?? []);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      } else if (showSnack) {
        SnackBarHelper.showErrorSnackBar(_responseErrorMessage(response));
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return state.filtered;
  }

  void _filterByKeyword<T>({
    required DataListState<T> state,
    required String keyWord,
    required bool Function(T item, String lowerKeyWord) matches,
  }) {
    if (keyWord.isEmpty) {
      state.resetFilter();
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      state.filter((item) => matches(item, lowerKeyWord));
    }
    notifyListeners();
  }

  String _responseErrorMessage(Response response) {
    final body = response.body;
    if (body is Map && body['message'] != null) return body['message'].toString();
    return response.statusText ?? 'Server Error';
  }
}
