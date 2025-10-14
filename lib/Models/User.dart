class User {
  User({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.createdAt,
  });

  final String? id;
  final String username;
  final String email;
  final String? fullName;
  final DateTime? createdAt;

  // Tạo User từ JSON (response từ API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"]?.toString() ?? json["id"]?.toString(),
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      fullName: json["fullName"],
      createdAt: json["createdAt"] != null 
          ? DateTime.parse(json["createdAt"].toString())
          : null,
    );
  }

  // Chuyển User thành JSON (gửi lên API)
  Map<String, dynamic> toJson() => {
        if (id != null) "_id": id,
        "username": username,
        "email": email,
        if (fullName != null) "fullName": fullName,
        "createdAt": createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };
}
