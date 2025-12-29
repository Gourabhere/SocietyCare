enum UserRole { staff, admin }

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String name;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.staff,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'staff',
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? name,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
