/// User model for authentication and user management
class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? title; // For administrators like "Father John"

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.title,
  });

  /// Creates a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.member,
      ),
      title: json['title'] as String?,
    );
  }

  /// Converts User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      if (title != null) 'title': title,
    };
  }

  /// Creates a copy of this User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? title,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      title: title ?? this.title,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.title == title;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, name, role, title);
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, title: $title)';
  }
}

/// Enum for user roles in the application
enum UserRole {
  member,
  administrator;

  /// Returns display name for the role
  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Member';
      case UserRole.administrator:
        return 'Administrator';
    }
  }
}