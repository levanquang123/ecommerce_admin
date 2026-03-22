class User {
  final String? sId;
  final String? email;
  final String? role;
  final String? createdAt;
  final String? updatedAt;

  User({this.sId, this.email, this.role, this.createdAt, this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sId: json['_id'],
      email: json['email'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'email': email,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
