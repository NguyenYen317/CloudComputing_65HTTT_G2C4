part of '../main.dart';

Map<String, String> _providerJsonHeaders(String? token) => {
  'Content-Type': 'application/json',
  if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
};

Map<String, String> _providerAuthHeaders(String? token) => {
  if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
};

Map<String, dynamic> _providerJsonMap(String body) {
  final decoded = jsonDecode(body);
  return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
}

List<dynamic> _providerJsonList(String body) {
  final decoded = jsonDecode(body);
  return decoded is List ? decoded : const [];
}

String _providerMessage(Map<String, dynamic> data, String fallback) {
  return data['message']?.toString() ?? fallback;
}

class AuthStateProvider extends ChangeNotifier {
  AppUser? currentUser;
  String? authToken;
  bool loading = false;
  String? error;

  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => currentUser?.role == 'admin';

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('currentUser');
    authToken = prefs.getString('authToken');

    if (userRaw == null) {
      currentUser = null;
      notifyListeners();
      return;
    }

    try {
      currentUser = AppUser.fromJson(jsonDecode(userRaw));
    } catch (_) {
      currentUser = null;
      authToken = null;
      await prefs.remove('currentUser');
      await prefs.remove('authToken');
    }

    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _emailAuth(
      path: ApiEndpoints.register,
      body: {'name': name, 'email': email, 'password': password},
      persistSession: false,
      fallbackError: 'Đăng ký thất bại',
    );
  }

  Future<bool> login({required String email, required String password}) {
    return _emailAuth(
      path: ApiEndpoints.login,
      body: {'email': email, 'password': password},
      fallbackError: 'Đăng nhập thất bại',
    );
  }

  Future<bool> syncFirebaseUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      error = 'Firebase không trả về thông tin tài khoản';
      notifyListeners();
      return false;
    }

    return _emailAuth(
      path: ApiEndpoints.googleLogin,
      body: {
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ?? firebaseUser.email ?? 'Google User',
        'avatar': firebaseUser.photoURL ?? '',
        'idToken': await firebaseUser.getIdToken(),
      },
      fallbackError: 'Đăng nhập Google thất bại',
    );
  }

  Future<bool> _emailAuth({
    required String path,
    required Map<String, dynamic> body,
    required String fallbackError,
    bool persistSession = true,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.post(
        ApiEndpoints.uri(path),
        headers: _providerJsonHeaders(null),
        body: jsonEncode(body),
      );
      final data = _providerJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (persistSession && data['user'] != null) {
          currentUser = AppUser.fromJson(data['user']);
          authToken = (data['token'] ?? '').toString();
          await saveSession();
        }
        return true;
      }

      error = _providerMessage(data, fallbackError);
      return false;
    } catch (err) {
      error = 'Không kết nối được API: $err';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> saveSession() async {
    final user = currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user.toJson()));
    await prefs.setString('authToken', authToken ?? '');
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('authToken');

    currentUser = null;
    authToken = null;
    error = null;
    notifyListeners();
  }
}
