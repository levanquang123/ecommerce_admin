class SubCategory {
  final String? sId;
  final String? name;
  final CategoryId? categoryId;
  final String? createdAt;
  final String? updatedAt;

  const SubCategory(
      {this.sId, this.name, this.categoryId, this.createdAt, this.updatedAt});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      sId: json["_id"],
      name: json["name"],
      categoryId: json["categoryId"] != null
          ? new CategoryId.fromJson(json["categoryId"])
          : null,
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "name": name,
      "categoryId": categoryId?.toJson(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class CategoryId {
  final String? sId;
  final String? name;

  const CategoryId({this.sId, this.name});

  factory CategoryId.fromJson(Map<String, dynamic> json) {
    return CategoryId(
      sId: json["sId"],
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
