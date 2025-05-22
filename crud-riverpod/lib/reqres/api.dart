import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asuka/asuka.dart' as asuka;

import 'models.dart';

class UserRepository {
  String baseUrl = "https://reqres.in/api/";
  String users = "users/";
  String apiKey = "reqres-free-v1";

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$users?page=1"),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<User> users = (data['data'] as List).map((json) => User.fromJson(json)).toList();

        asuka.AsukaSnackbar.success(
          'Users loaded successfully!',
        ).show();

        return users;
      } else {
        asuka.AsukaSnackbar.alert(
          'Failed to load users',
        ).show();
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      asuka.AsukaSnackbar.alert(
        'Error: $e',
      ).show();
      rethrow;
    }
  }

  Future<User> createUser (String name, String job) async {
    final response = await http.post(
      Uri.parse('$baseUrl$users'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: json.encode({
        'name': name,
        'job': job,
      }),
    );
    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      asuka.AsukaSnackbar.success('User added successfully!').show();
      print('create user done');
      print(response);
      return User.fromJson({
        'name': jsonResponse['name'],
        'job': jsonResponse['job'],
        'id': jsonResponse['id'],
      });
    } else {
      asuka.AsukaSnackbar.alert(
        'Failed to create users : ${response.body}',
      ).show();
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<User> updateUser (int id, String name, String job) async {
    final response = await http.put(
      Uri.parse('$baseUrl$users$id'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: json.encode({
        'name': name,
        'job': job,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      asuka.AsukaSnackbar.success('User updated successfully!').show();
      print('update done');
      print(response);
      return User.fromJson({
        'name': jsonResponse['name'],
        'job': jsonResponse['job'],
      });
    } else {
      asuka.AsukaSnackbar.alert(
        'Failed to update users : ${response.body}',
      ).show();
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<void> deleteUser (int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$users$id'),
      headers: {
        'x-api-key': apiKey,
      },
    );
    if (response.statusCode == 204) {
      asuka.AsukaSnackbar.success('User deleted successfully!').show();
      print(response);
      print('delete done');
    } else {
      asuka.AsukaSnackbar.alert(
        'Failed to delete user : ${response.body}',
      ).show();
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}