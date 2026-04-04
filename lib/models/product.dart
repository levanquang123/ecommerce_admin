class Product {
  String? sId;
  String? name;
  String? description;
  int? quantity;
  double? price;
  double? offerPrice;
  ProRef? proCategoryId;
  ProRef? proSubCategoryId;
  ProRef? proBrandId;
  ProTypeRef? proVariantTypeId;
  List<String>? proVariantId;
  List<Images>? images;
  List<ProductVariant>? variants;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Product(
      {this.sId,
        this.name,
        this.description,
        this.quantity,
        this.price,
        this.offerPrice,
        this.proCategoryId,
        this.proSubCategoryId,
        this.proBrandId,
        this.proVariantTypeId,
        this.proVariantId,
        this.images,
        this.variants,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    quantity = json['quantity'];
    price = json['price']?.toDouble();
    offerPrice = json['offerPrice']?.toDouble();
    proCategoryId = json['proCategoryId'] != null
        ? new ProRef.fromJson(json['proCategoryId'])
        : null;
    proSubCategoryId = json['proSubCategoryId'] != null
        ? new ProRef.fromJson(json['proSubCategoryId'])
        : null;
    proBrandId = json['proBrandId'] != null
        ? new ProRef.fromJson(json['proBrandId'])
        : null;
    proVariantTypeId = json['proVariantTypeId'] != null
        ? new ProTypeRef.fromJson(json['proVariantTypeId'])
        : null;
    proVariantId = (json['proVariantId'] as List?)
        ?.map((e) => e.toString())
        .toList();
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    if (json['variants'] != null) {
      variants = <ProductVariant>[];
      json['variants'].forEach((v) {
        variants!.add(ProductVariant.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['offerPrice'] = this.offerPrice;
    if (this.proCategoryId != null) {
      data['proCategoryId'] = this.proCategoryId!.toJson();
    }
    if (this.proSubCategoryId != null) {
      data['proSubCategoryId'] = this.proSubCategoryId!.toJson();
    }
    if (this.proBrandId != null) {
      data['proBrandId'] = this.proBrandId!.toJson();
    }
    if (this.proVariantTypeId != null) {
      data['proVariantTypeId'] = this.proVariantTypeId!.toJson();
    }
    data['proVariantId'] = this.proVariantId;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class ProRef {
  String? sId;
  String? name;

  ProRef({this.sId, this.name});

  ProRef.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}

class ProTypeRef {
  String? sId;
  String? type;

  ProTypeRef({this.sId, this.type});

  ProTypeRef.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['type'] = this.type;
    return data;
  }
}

class Images {
  int? image;
  String? url;
  String? sId;

  Images({this.image, this.url, this.sId});

  Images.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    url = json['url'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['url'] = this.url;
    data['_id'] = this.sId;
    return data;
  }

}

class ProductVariant {
  String? sId;
  String sku;
  List<ProductVariantAttribute> attributes;
  double price;
  double? offerPrice;
  int quantity;
  List<VariantImage> images;
  bool isActive;

  ProductVariant({
    this.sId,
    required this.sku,
    required this.attributes,
    required this.price,
    this.offerPrice,
    required this.quantity,
    required this.images,
    this.isActive = true,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'];
    List<ProductVariantAttribute> parsedAttributes = [];

    if (rawAttributes is List) {
      parsedAttributes = rawAttributes
          .map((item) => ProductVariantAttribute.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>)))
          .toList();
    }

    final rawImages = json['images'];
    List<VariantImage> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages
          .map((item) => VariantImage.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>)))
          .toList();
    }

    return ProductVariant(
      sId: json['_id'],
      sku: (json['sku'] ?? '').toString(),
      attributes: parsedAttributes,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      images: parsedImages,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sId != null) '_id': sId,
      'sku': sku,
      'attributes': attributes.map((e) => e.toJson()).toList(),
      'price': price,
      'offerPrice': offerPrice,
      'quantity': quantity,
      'images': images.map((e) => e.toJson()).toList(),
      'isActive': isActive,
    };
  }
}

class ProductVariantAttribute {
  VariantNode? variantType;
  VariantNode? variant;

  ProductVariantAttribute({
    this.variantType,
    this.variant,
  });

  factory ProductVariantAttribute.fromJson(Map<String, dynamic> json) {
    return ProductVariantAttribute(
      variantType: VariantNode.fromAny(json['variantTypeId']),
      variant: VariantNode.fromAny(json['variantId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantTypeId': variantType?.sId,
      'variantId': variant?.sId,
    };
  }
}

class VariantNode {
  String? sId;
  String? name;
  String? type;

  VariantNode({
    this.sId,
    this.name,
    this.type,
  });

  factory VariantNode.fromAny(dynamic value) {
    if (value == null) return VariantNode();
    if (value is String) {
      return VariantNode(sId: value);
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
      return VariantNode(
        sId: map['_id']?.toString(),
        name: map['name']?.toString(),
        type: map['type']?.toString(),
      );
    }
    return VariantNode();
  }
}

class VariantImage {
  int image;
  String url;

  VariantImage({
    required this.image,
    required this.url,
  });

  factory VariantImage.fromJson(Map<String, dynamic> json) {
    return VariantImage(
      image: (json['image'] as num?)?.toInt() ?? 1,
      url: (json['url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'url': url,
    };
  }
}

