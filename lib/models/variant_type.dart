class VariantType {
  final String? name;
  final String? type;
  final String? sId;
  final String? createdAt;
  final String? updatedAt;

  const VariantType({
    this.name,
    this.type,
    this.sId,
    this.createdAt,
    this.updatedAt,
  });

  factory VariantType.fromJson(Map<String, dynamic> json) {
    return VariantType(
      name: json["name"],
      type: json["type"],
      sId: json["_id"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "_id": sId,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
