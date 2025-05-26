import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:asuka/asuka.dart' as asuka;
import 'models.dart';

part 'api.g.dart'; // This will be generated

const String baseUrl = "https://reqres.in/api/";
const String usersEndpoint = "users/";
const String apiKey = "reqres-free-v1";

@Riverpod(keepAlive: true)
class UserAPI extends _$UserAPI {
  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse("$baseUrl$usersEndpoint?page=1"),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  @override
  Future<List<User>> build() async {
    return await fetchUsers();
  }

  Future<void> refreshUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final users = await fetchUsers();
      asuka.AsukaSnackbar.success('Users loaded successfully!').show();
      return users;
    });
  }

  Future<User> createUser(String name, String job) async {
    final response = await http.post(
      Uri.parse('$baseUrl$usersEndpoint'),
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
      return User.fromJson({
        'name': jsonResponse['name'],
        'job': jsonResponse['job'],
        'id': jsonResponse['id'],
      });
    } else {
      asuka.AsukaSnackbar.alert('Failed to create user: ${response.body}').show();
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<User> updateUser(int id, String name, String job) async {
    final response = await http.put(
      Uri.parse('$baseUrl$usersEndpoint$id'),
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
      return User.fromJson({
        'name': jsonResponse['name'],
        'job': jsonResponse['job'],
      });
    } else {
      asuka.AsukaSnackbar.alert('Failed to update user: ${response.body}').show();
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$usersEndpoint$id'),
      headers: {
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode == 204) {
      asuka.AsukaSnackbar.success('User deleted successfully!').show();
    } else {
      asuka.AsukaSnackbar.alert('Failed to delete user: ${response.body}').show();
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}