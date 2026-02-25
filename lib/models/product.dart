class Product {
  final String? sId;
  final String? name;
  final String? description;
  final int? quantity;
  final int? price;
  final int? offerPrice;
  final List<Images>? images;
  final ProRef? proCategoryId;
  final ProRef? proSubCategoryId;
  final ProRef? proBrandId;
  final ProTypeRef? proVariantTypeId;
  final List<String>? proVariantId;
  final String? createdAt;
  final String? updatedAt;
  final int? iV;

  const Product({
    this.sId,
    this.name,
    this.description,
    this.quantity,
    this.price,
    this.offerPrice,
    this.images,
    this.proCategoryId,
    this.proSubCategoryId,
    this.proBrandId,
    this.proVariantTypeId,
    this.proVariantId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sId: json['_id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      price: json['price']?.toDouble(),
      offerPrice: json['offerPrice']?.toDouble(),
      proCategoryId: json['proCategoryId'] != null
          ? ProRef.fromJson(json['proCategoryId'])
          : null,
      proSubCategoryId: json['proSubCategoryId'] != null
          ? ProRef.fromJson(json['proSubCategoryId'])
          : null,
      proBrandId: json['proBrandId'] != null
          ? ProRef.fromJson(json['proBrandId'])
          : null,
      proVariantTypeId: json['proVariantTypeId'] != null
          ? ProTypeRef.fromJson(json['proVariantTypeId'])
          : null,
      proVariantId: json['proVariantId'] != null
          ? List<String>.from(json['proVariantId'])
          : [],
      images: json['images'] != null
          ? List<Images>.from(
        json['images'].map((v) => Images.fromJson(v)),
      )
          : [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'offerPrice': offerPrice,
      'proCategoryId': proCategoryId?.toJson(),
      'proSubCategoryId': proSubCategoryId?.toJson(),
      'proBrandId': proBrandId?.toJson(),
      'proVariantTypeId': proVariantTypeId?.toJson(),
      'proVariantId': proVariantId,
      'images': images?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
    };
  }
}

class ProRef {
  final String? sId;
  final String? name;

  const ProRef({this.sId, this.name});

  factory ProRef.fromJson(Map<String, dynamic> json) {
    return ProRef(
      sId: json["_id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "name": name,
    };
  }
}

class ProTypeRef {
  final String? sId;
  final String? type;

  const ProTypeRef({this.sId, this.type});

  factory ProTypeRef.fromJson(Map<String, dynamic> json) {
    return ProTypeRef(
      sId: json["_id"],
      type: json["type"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "type": type,
    };
  }
}

class Images {
  final String? url;
  final int? image;
  final String? sId;

  Images({this.url, this.image, this.sId});

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
        url: json["url"], image: json["image"].toDouble(), sId: json["_id"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "image": image,
      "_id": sId,
    };
  }
}
