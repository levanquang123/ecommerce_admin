class MyNotification {
  final String? sId;
  final String? notificationId;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;
  final int? iV;

  const MyNotification(
      {this.sId,
      this.notificationId,
      this.title,
      this.description,
      this.imageUrl,
      this.createdAt,
      this.updatedAt,
      this.iV});

  factory MyNotification.fromJson(Map<String, dynamic> json) {
    return MyNotification(
      sId: json['_id'],
      notificationId: json['notificationId'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'notificationId': notificationId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
    };
  }
}
