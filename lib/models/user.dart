class User {
  final String? sId;
  final String? name;
  final String? role;
  final String? createdAt;
  final String? updatedAt;

  User({this.sId, this.name, this.role, this.createdAt, this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'],
      name: json['name'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
