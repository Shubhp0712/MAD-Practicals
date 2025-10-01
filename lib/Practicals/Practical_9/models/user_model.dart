class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String name;
  final String avatar;
  final bool twoFactorEnabled;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.name,
    required this.avatar,
    this.twoFactorEnabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'name': name,
      'avatar': avatar,
      'twoFactorEnabled': twoFactorEnabled,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  final bool requiresTwoFactor;
  final String? tempToken;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.requiresTwoFactor = false,
    this.tempToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      tempToken: json['tempToken'],
    );
  }
}
