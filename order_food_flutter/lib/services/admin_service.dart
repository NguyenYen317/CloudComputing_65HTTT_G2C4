// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../main.dart';

extension AdminServiceMethods on _HomePageState {
  Future<void> fetchAdminData() async {
    await fetchOrders(all: true);

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users'),
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          adminUsers = data
              .map((item) => AppUser.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        });
      }
    } catch (_) {}

    await fetchMlPredictions();
    await fetchBigQueryEvents();
  }

  Future<void> deleteCustomerUser(AppUser user) async {
    if (user.role == 'admin') {
      showMessage('Không thể xóa tài khoản admin');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản khách?'),
        content: Text('Tài khoản ${user.email} sẽ bị xóa khỏi hệ thống.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/users/${Uri.encodeComponent(user.email)}'),
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(
          () => adminUsers.removeWhere((item) => item.email == user.email),
        );
        showMessage(data['message']?.toString() ?? 'Đã xóa tài khoản khách');
      } else {
        showMessage(data['message']?.toString() ?? 'Xóa tài khoản thất bại');
      }
    } catch (error) {
      showMessage('Không xóa được tài khoản: $error');
    }
  }
}
