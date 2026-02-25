class Coupon {
  final String? sId;
  final String? couponCode;
  final String? discountType;
  final double? discountAmount;
  final double? minimumPurchaseAmount;
  final String? endDate;
  final String? status;
  final CatRef? applicableCategory;
  final CatRef? applicableSubCategory;
  final CatRef? applicableProduct;
  final String? createdAt;
  final String? updatedAt;
  final int? iV;

  const Coupon(
      {this.sId,
      this.couponCode,
      this.discountType,
      this.discountAmount,
      this.minimumPurchaseAmount,
      this.endDate,
      this.status,
      this.applicableCategory,
      this.applicableSubCategory,
      this.applicableProduct,
      this.createdAt,
      this.updatedAt,
      this.iV});

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      sId: json['_id'],
      couponCode: json['couponCode'],
      discountType: json['discountType'],
      discountAmount: json['discountAmount']?.toDouble(),
      minimumPurchaseAmount: json['minimumPurchaseAmount']?.toDouble(),
      endDate: json['endDate'],
      status: json['status'],
      applicableCategory: json['applicableCategory'] != null
          ? CatRef.fromJson(json['applicableCategory'])
          : null,
      applicableSubCategory: json['applicableSubCategory'] != null
          ? CatRef.fromJson(json['applicableSubCategory'])
          : null,
      applicableProduct: json['applicableProduct'] != null
          ? CatRef.fromJson(json['applicableProduct'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "couponCode": couponCode,
      "discountType": discountType,
      "discountAmount": discountAmount,
      "minimumPurchaseAmount": minimumPurchaseAmount,
      "endDate": endDate,
      "status": status,
      "applicableCategory": applicableCategory?.toJson(),
      "applicableSubCategory": applicableSubCategory?.toJson(),
      "applicableProduct": applicableProduct?.toJson(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": iV,
    };
  }
}

class CatRef {
  final String? sId;
  final String? name;

  const CatRef({this.sId, this.name});

  factory CatRef.fromJson(Map<String, dynamic> json) {
    return CatRef(
      sId: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
    };
  }
}
