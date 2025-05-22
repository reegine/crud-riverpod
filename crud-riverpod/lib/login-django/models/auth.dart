class AuthUser  {
  final String token;
  final String email;
  final String username;
  final int userId;

  AuthUser ({
    required this.token,
    required this.email,
    required this.username,
    required this.userId,
  });

  factory AuthUser .empty() => AuthUser (token: '', email: '', username: '', userId: 0);

  factory AuthUser .fromLoginJson(Map<String, dynamic> json) {
    return AuthUser (
      token: json['auth_token'] ?? json['token'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      userId: json['user_id'] ?? 0,
    );
  }

  factory AuthUser .fromRegisterJson(Map<String, dynamic> json) {
    return AuthUser (
      token: '',
      email: json['email'],
      username: json['username'],
      userId: 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'email': email,
    'username': username,
    'user_id': userId,
  };
}