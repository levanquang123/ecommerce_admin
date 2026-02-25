class Variant {
  final String? sId;
  final String? name;
  final VariantTypeId? variantTypeId;
  final String? createdAt;
  final String? updatedAt;

  const Variant(
      {this.sId,
      this.name,
      this.variantTypeId,
      this.createdAt,
      this.updatedAt});

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      sId: json['_id'],
      name: json['name'],
      variantTypeId: json['variantTypeId'] != null
          ? VariantTypeId.fromJson(json['variantTypeId'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'variantTypeId': variantTypeId?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class VariantTypeId {
  final String? sId;
  final String? name;
  final String? type;
  final String? createdAt;
  final String? updatedAt;

  const VariantTypeId(
      {this.sId, this.name, this.type, this.createdAt, this.updatedAt});

  factory VariantTypeId.fromJson(Map<String, dynamic> json) {
    return VariantTypeId(
      sId: json['_id'],
      name: json['name'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
