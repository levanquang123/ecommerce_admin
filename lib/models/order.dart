class Order {
  final ShippingAddress? shippingAddress;
  final OrderTotal? orderTotal;
  final String? sId;
  final UserID? userID;
  final String? orderStatus;
  final List<Items>? items;
  final double? totalPrice;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentIntentId;
  final CouponCode? couponCode;
  final String? trackingUrl;
  final String? orderDate;
  final int? iV;

  const Order({
    this.shippingAddress,
    this.orderTotal,
    this.sId,
    this.userID,
    this.orderStatus,
    this.items,
    this.totalPrice,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentIntentId,
    this.couponCode,
    this.trackingUrl,
    this.orderDate,
    this.iV,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromJson(json['shippingAddress'])
          : null,
      orderTotal: json['orderTotal'] != null
          ? OrderTotal.fromJson(json['orderTotal'])
          : null,
      sId: json['_id'],
      userID: json['userID'] != null && json['userID'] is Map
          ? UserID.fromJson(json['userID'])
          : (json['userID'] is String ? UserID(sId: json['userID']) : null),
      orderStatus: json['orderStatus'],
      items: json['items'] != null
          ? List<Items>.from(
        json['items'].map((x) => Items.fromJson(x)),
      )
          : null,
      totalPrice: json['totalPrice']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus']?.toString(),
      paymentIntentId: json['paymentIntentId']?.toString(),
      couponCode: json['couponCode'] != null
          ? CouponCode.fromJson(json['couponCode'])
          : null,
      trackingUrl: json['trackingUrl'],
      orderDate: json['orderDate'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (shippingAddress != null)
      'shippingAddress': shippingAddress!.toJson(),
    if (orderTotal != null)
      'orderTotal': orderTotal!.toJson(),
    '_id': sId,
    if (userID != null) 'userID': userID!.toJson(),
    'orderStatus': orderStatus,
    if (items != null)
      'items': items!.map((x) => x.toJson()).toList(),
    'totalPrice': totalPrice,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus,
    'paymentIntentId': paymentIntentId,
    if (couponCode != null)
      'couponCode': couponCode!.toJson(),
    'trackingUrl': trackingUrl,
    'orderDate': orderDate,
    '__v': iV,
  };
}

class ShippingAddress {
  final String? phone;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  const ShippingAddress({
    this.phone,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      phone: json['phone']?.toString(),
      street: json['street']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postalCode']?.toString(),
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

class OrderTotal {
  final double? subtotal;
  final double? discount;
  final double? total;

  const OrderTotal({this.subtotal, this.discount, this.total});

  factory OrderTotal.fromJson(Map<String, dynamic> json) {
    return OrderTotal(
      subtotal: json['subtotal']?.toDouble(),
      discount: json['discount']?.toDouble(),
      total: json['total']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
    };
  }
}

class UserID {
  final String? sId;
  final String? email;
  final String? role;

  const UserID({this.sId, this.email, this.role});

  factory UserID.fromJson(Map<String, dynamic> json) {
    return UserID(
      sId: json['_id']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'email': email,
      'role': role,
    };
  }
}

class Items {
  final String? productID;
  final String? productName;
  final int? quantity;
  final double? price;
  final String? variant;
  final String? sId;

  const Items({
    this.productID,
    this.productName,
    this.quantity,
    this.price,
    this.variant,
    this.sId,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      productID: json['productID']?.toString(),
      productName: json['productName']?.toString(),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '0'),
      price: json['price']?.toDouble(),
      variant: json['variant']?.toString(),
      sId: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'variant': variant,
      '_id': sId,
    };
  }
}

class CouponCode {
  final String? sId;
  final String? couponCode;
  final String? discountType;
  final int? discountAmount;

  const CouponCode({
    this.sId,
    this.couponCode,
    this.discountType,
    this.discountAmount,
  });

  factory CouponCode.fromJson(Map<String, dynamic> json) {
    return CouponCode(
      sId: json['_id']?.toString(),
      couponCode: json['couponCode']?.toString(),
      discountType: json['discountType']?.toString(),
      discountAmount: json['discountAmount'] is int ? json['discountAmount'] : int.tryParse(json['discountAmount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'couponCode': couponCode,
      'discountType': discountType,
      'discountAmount': discountAmount,
    };
  }
}
