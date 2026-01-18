class User {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin', 'teacher', 'student'

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password, 'role': role};
  }

  // Implement a factory constructor for creating a new User instance from a map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
    );
  }

  User copyWith({int? id, String? username, String? password, String? role}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
