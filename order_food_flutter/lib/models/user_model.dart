part of '../main.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'customer',
    this.avatar = '',
    this.provider = 'email',
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String avatar;
  final String provider;

  factory AppUser.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    final email = (data['email'] ?? '').toString();
    return AppUser(
      id: (data['id'] ?? data['userId'] ?? email).toString(),
      name: (data['name'] ?? email).toString(),
      email: email,
      role: (data['role'] ?? 'customer').toString(),
      avatar: (data['avatar'] ?? '').toString(),
      provider: (data['provider'] ?? 'email').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'avatar': avatar,
    'provider': provider,
  };
}
