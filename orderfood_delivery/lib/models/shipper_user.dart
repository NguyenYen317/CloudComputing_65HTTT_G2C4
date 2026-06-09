class ShipperUser {
  const ShipperUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  factory ShipperUser.fromLoginJson(Map<String, dynamic> data) {
    final user = Map<String, dynamic>.from(data['user'] as Map? ?? {});
    return ShipperUser(
      id: (user['id'] ?? user['userId'] ?? '').toString(),
      name: (user['name'] ?? 'Shipper').toString(),
      email: (user['email'] ?? '').toString(),
      role: (user['role'] ?? '').toString(),
      token: (data['token'] ?? '').toString(),
    );
  }
}
