class Brand {
  final String? sId;
  final String? name;
  final SubcategoryId? subcategoryId;
  final String? createdAt;
  final String? updatedAt;

  const Brand(
      {this.sId,
      this.name,
      this.subcategoryId,
      this.createdAt,
      this.updatedAt});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      sId: json['_id'],
      name: json['name'],
      subcategoryId: json['subcategoryId'] != null
          ? new SubcategoryId.fromJson(json['subcategoryId'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "name": name,
      "subcategoryId": subcategoryId?.toJson(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class SubcategoryId {
  final String? sId;
  final String? name;
  final String? categoryId;
  final String? createdAt;
  final String? updatedAt;

  const SubcategoryId(
      {this.sId, this.name, this.categoryId, this.createdAt, this.updatedAt});

  factory SubcategoryId.fromJson(Map<String, dynamic> json) {
    return SubcategoryId(
      sId: json['_id'],
      name: json['name'],
      categoryId: json['categoryId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "name": name,
      "categoryId": categoryId,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
