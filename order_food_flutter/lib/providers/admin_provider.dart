part of '../main.dart';

class AdminProvider extends ChangeNotifier {
  Map<String, dynamic>? dashboard;
  List<AppUser> users = [];
  bool loading = false;
  String? error;

  Future<void> fetchDashboard(String? token) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.get(
        ApiEndpoints.uri('/admin/dashboard'),
        headers: _providerAuthHeaders(token),
      );
      if (response.statusCode == 200) {
        dashboard = _providerJsonMap(response.body);
      } else {
        error = 'Không tải được dashboard';
      }
    } catch (err) {
      error = 'Không kết nối được API admin: $err';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers(String? token) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.get(
        ApiEndpoints.uri(ApiEndpoints.users),
        headers: _providerAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        users = _providerJsonList(response.body)
            .map((item) => AppUser.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        error = 'Không tải được danh sách người dùng';
      }
    } catch (err) {
      error = 'Không kết nối được API người dùng: $err';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomerUser(AppUser user, String? token) async {
    if (user.role == 'admin') {
      error = 'Không thể xóa tài khoản admin';
      notifyListeners();
      return false;
    }

    try {
      final response = await http.delete(
        ApiEndpoints.uri(
          '${ApiEndpoints.users}/${Uri.encodeComponent(user.email)}',
        ),
        headers: _providerAuthHeaders(token),
      );
      final data = _providerJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        users.removeWhere((item) => item.email == user.email);
        notifyListeners();
        return true;
      }

      error = _providerMessage(data, 'Xóa tài khoản thất bại');
      notifyListeners();
      return false;
    } catch (err) {
      error = 'Không xóa được tài khoản: $err';
      notifyListeners();
      return false;
    }
  }
}
