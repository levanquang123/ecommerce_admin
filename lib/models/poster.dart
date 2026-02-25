class Poster {
  final String? sId;
  final String? posterName;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;
  final int? iV;

  const Poster(
      {this.sId,
      this.posterName,
      this.imageUrl,
      this.createdAt,
      this.updatedAt,
      this.iV});

  factory Poster.fromJson(Map<String, dynamic> json) {
    return Poster(
      sId: json['_id'],
      posterName: json['posterName'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'posterName': posterName,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
    };
  }
}
