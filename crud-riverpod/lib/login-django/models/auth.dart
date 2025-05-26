import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; // Must include this

part 'auth.freezed.dart';
part 'auth.g.dart'; // This is what we want to generate

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String token,
    String? email,
    String? username,
    int? userId,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}
