class Category {
  final String? sId;
  final String? name;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const Category(
      {this.sId, this.name, this.image, this.createdAt, this.updatedAt});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      sId: json["_id"],
      name: json["name"],
      image: json["image"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "name": name,
      "image": image,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
