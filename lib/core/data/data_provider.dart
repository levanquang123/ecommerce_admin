import 'package:flutter/material.dart';

import '../../models/api_response.dart';
import '../../models/coupon.dart';
import '../../models/my_notification.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/variant_type.dart';
import '../../services/http_services.dart';
import '../../utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../../models/category.dart';
import '../../models/brand.dart';
import '../../models/sub_category.dart';
import '../../models/variant.dart';

class DataProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];

  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];

  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];

  List<Brand> get brands => _filteredBrands;

  List<VariantType> _allVariantTypes = [];
  List<VariantType> _filteredVariantTypes = [];

  List<VariantType> get variantTypes => _filteredVariantTypes;

  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];

  List<Variant> get variants => _filteredVariants;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  List<Product> get products => _filteredProducts;

  List<Coupon> _allCoupons = [];
  List<Coupon> _filteredCoupons = [];

  List<Coupon> get coupons => _filteredCoupons;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];

  List<Poster> get posters => _filteredPosters;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];

  List<Order> get orders => _filteredOrders;

  List<MyNotification> _allNotifications = [];
  List<MyNotification> _filteredNotifications = [];

  List<MyNotification> get notifications => _filteredNotifications;

  DataProvider();

  bool isLoading = false;

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
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "categories");
      if (response.isOk) {
        ApiResponse<List<Category>> apiResponse =
            ApiResponse<List<Category>>.fromJson(
                response.body,
                (json) => (json as List)
                    .map((item) => Category.fromJson(item))
                    .toList());
        _allCategories = apiResponse.data ?? [];
        _filteredCategories = List.from(_allCategories);
        notifyListeners();
        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredCategories;
  }

  void filterCategories(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? "").toLowerCase().contains(lowerKeyWord);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "SubCategories");
      if (response.isOk) {
        ApiResponse<List<SubCategory>> apiResponse =
            ApiResponse<List<SubCategory>>.fromJson(
                response.body,
                (json) => (json as List)
                    .map((item) => SubCategory.fromJson(item))
                    .toList());
        _allSubCategories = apiResponse.data ?? [];
        _filteredSubCategories = List.from(_allSubCategories);
        notifyListeners();
        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredSubCategories;
  }

  void filterSubCategories(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredSubCategories = _allSubCategories.where((subCategory) {
        return (subCategory.name ?? "").toLowerCase().contains(lowerKeyWord);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "brands");
      if (response.isOk) {
        ApiResponse<List<Brand>> apiResponse =
            ApiResponse<List<Brand>>.fromJson(
                response.body,
                (json) => (json as List)
                    .map((item) => Brand.fromJson(item))
                    .toList());

        _allBrands = apiResponse.data ?? [];
        _filteredBrands = List.from(_allBrands);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(e.toString());
      }
      rethrow;
    }
    return _filteredBrands;
  }

  void filterBrands(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredBrands = _allBrands.where((brand) {
        return (brand.name ?? "").toLowerCase().contains(lowerKeyWord);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<VariantType>> getAllVariantTypes({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "variantTypes");
      if (response.isOk) {
        ApiResponse<List<VariantType>> apiResponse =
            ApiResponse<List<VariantType>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => VariantType.fromJson(item)).toList(),
        );

        _allVariantTypes = apiResponse.data ?? [];
        _filteredVariantTypes = List.from(_allVariantTypes);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredVariantTypes;
  }

  void filterVariantTypes(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredVariantTypes = List.from(_allVariantTypes);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredVariantTypes = _allVariantTypes.where((variantType) {
        final name = (variantType.name ?? "").toLowerCase();
        final type = (variantType.type ?? "").toLowerCase();
        return name.contains(lowerKeyWord) || type.contains(lowerKeyWord);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Variant>> getAllVariant({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "variants");
      if (response.isOk) {
        ApiResponse<List<Variant>> apiResponse =
            ApiResponse<List<Variant>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Variant.fromJson(item)).toList(),
        );

        _allVariants = apiResponse.data ?? [];
        _filteredVariants = List.from(_allVariants);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredVariants;
  }

  void filterVariant(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredVariants = List.from(_allVariants);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredVariants = _allVariants.where((variant) {
        final name = (variant.name ?? "").toLowerCase();
        final typeName = (variant.variantTypeId?.name ?? "").toLowerCase();
        return name.contains(lowerKeyWord) || typeName.contains(lowerKeyWord);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Product>> getAllProducts({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'products');
      if (response.isOk) {
        ApiResponse<List<Product>> apiResponse =
            ApiResponse<List<Product>>.fromJson(
          response.body,
          (json) => (json as List).map((e) => Product.fromJson(e)).toList(),
        );

        _allProducts = apiResponse.data ?? [];
        _filteredProducts = List.from(_allProducts);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(e.toString());
      }
      rethrow;
    }
    return _filteredProducts;
  }

  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredProducts = _allProducts.where((product) {
        final name = (product.name ?? '').toLowerCase();
        final category = (product.proCategoryId?.name ?? '').toLowerCase();
        final brand = (product.proBrandId?.name ?? '').toLowerCase();
        return name.contains(lowerKeyword) ||
            category.contains(lowerKeyword) ||
            brand.contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Coupon>> getAllCoupons({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "couponCodes");

      if (response.isOk) {
        ApiResponse<List<Coupon>> apiResponse =
            ApiResponse<List<Coupon>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Coupon.fromJson(item)).toList(),
        );

        _allCoupons = apiResponse.data ?? [];
        _filteredCoupons = List.from(_allCoupons);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            response.body?['message'] ?? response.statusText ?? "Server Error",
          );
        }
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }

    return _filteredCoupons;
  }

  void filterCoupons(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredCoupons = List.from(_allCoupons);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredCoupons = _allCoupons.where((coupon) {
        return (coupon.couponCode ?? "").toLowerCase().contains(lowerKeyWord);
      }).toList();
    }

    notifyListeners();
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: "posters");
      if (response.isOk) {
        ApiResponse<List<Poster>> apiResponse =
            ApiResponse<List<Poster>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Poster.fromJson(item)).toList(),
        );

        _allPosters = apiResponse.data ?? [];
        _filteredPosters = List.from(_allPosters);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
            response.body?['message'] ?? response.statusText ?? "Server Error",
          );
        }
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredPosters;
  }

  void filterPosters(String keyWord) {
    if (keyWord.isEmpty) {
      _filteredPosters = List.from(_allPosters);
    } else {
      final lowerKeyWord = keyWord.toLowerCase();
      _filteredPosters = _allPosters.where((poster) {
        final name = (poster.posterName ?? "").toLowerCase();
        return name.contains(lowerKeyWord);
      }).toList();
    }
    notifyListeners();
  }

//TODO: should complete getAllNotifications

//TODO: should complete filterNotifications

//TODO: should complete getAllOrders

//TODO: should complete filterOrders

//TODO: should complete calculateOrdersWithStatus

  filterProductsByQuantity(String productQntType) {
    if (productQntType == "All products") {
      _filteredProducts = List.from(_allProducts);
    } else if (productQntType == "Out of Stock") {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 0;
      }).toList();
    } else if (productQntType == "Limited Stock") {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 1;
      }).toList();
    } else if (productQntType == "Other Stock") {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null &&
            product.quantity != 0 &&
            product.quantity != 1;
      }).toList();
    }
    notifyListeners();
  }

  calculateProductWithQuantity({int? quantity}) {
    int totalOrders = 0;
    if (quantity == null) {
      totalOrders = _allProducts.length;
    } else {
      for (Product product in _allProducts) {
        if (product.quantity != null && product.quantity == quantity) {
          totalOrders++;
        }
      }
    }
    return totalOrders;
  }
}
