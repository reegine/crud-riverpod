import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/auth.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.1.12:8000';
  final http.Client client;

  AuthService({required this.client});

  Future<AuthUser> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/token/login/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final token = body['auth_token']; // Adjust key to match your backend

      if (token == null) {
        throw Exception('Token missing from login response');
      }

      // Fetch full user info using the token
      final user = await fetchUserInfo(token);

      // Return user with token manually inserted
      return user.copyWith(token: token);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? error['non_field_errors']?.first ?? 'Login failed');
    }
  }


  Future<AuthUser> register(String email, String username, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/users/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return AuthUser.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      final errorMessage = error.values.first is List
          ? error.values.first.first
          : 'Registration failed';
      throw Exception(errorMessage);
    }
  }

  Future<void> logout(String token) async {
    print(token);
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/token/logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode != 204) {
      print(response.body);
      throw Exception('Logout failed');
    }
  }

  Future<AuthUser > fetchUserInfo(String token) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/auth/users/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final userJson = json.decode(response.body);
      return AuthUser.fromJson(userJson);
    } else {
      throw Exception('Failed to fetch user info');
    }
  }

  Future<AuthUser> updateUserEmail(String token, String newEmail) async {
    final response = await client.patch(
      Uri.parse('$_baseUrl/auth/users/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({'email': newEmail}),
    );

    if (response.statusCode == 200) {
      final userJson = json.decode(response.body);
      return AuthUser.fromJson(userJson);
    } else {
      throw Exception('Failed to update email: ${response.body}');
    }
  }

}