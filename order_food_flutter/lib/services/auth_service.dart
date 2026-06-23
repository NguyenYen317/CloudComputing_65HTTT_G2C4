// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../main.dart';

extension AuthServiceMethods on _HomePageState {
  Future<void> initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: googleClientId.isEmpty ? null : googleClientId,
        serverClientId: googleServerClientId.isEmpty
            ? null
            : googleServerClientId,
      );
      setState(() => googleReady = true);
    } catch (error) {
      debugPrint('Google Sign-In init failed: $error');
    }
  }

  Future<void> loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('currentUser');
    authToken = prefs.getString('authToken');
    storedCartRaw = prefs.getString('cartItems');

    if (userRaw != null) {
      try {
        setState(() => currentUser = AppUser.fromJson(jsonDecode(userRaw)));
        if (currentUser?.role == 'admin') {
          await fetchAdminData();
        } else {
          await fetchOrders();
          await fetchCart();
        }
      } catch (_) {
        await prefs.remove('currentUser');
        await prefs.remove('authToken');
      }
    }

    // load rated orders
    final rated = prefs.getStringList('ratedOrders') ?? [];
    setState(() => ratedOrders.addAll(rated));

    restoreCartFromStorage();
  }

  Future<void> saveSession() async {
    final user = currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user.toJson()));
    await prefs.setString('authToken', authToken ?? '');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('authToken');
  }

  Future<void> submitEmailAuth() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty || (registering && name.isEmpty)) {
      showMessage('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setState(() => authLoading = true);
    final endpoint = registering ? '/auth/register' : '/auth/login';

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (registering) {
          setState(() {
            registering = false;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
          });
          showMessage('Đăng ký thành công. Vui lòng đăng nhập lại.');
          return;
        }

        setState(() {
          currentUser = AppUser.fromJson(data['user']);
          authToken = (data['token'] ?? '').toString();
        });
        await saveSession();
        if (currentUser?.role == 'admin') {
          await fetchAdminData();
        } else {
          await fetchOrders();
          await fetchCart();
        }
        showMessage(data['message']?.toString() ?? 'Đăng nhập thành công');
      } else {
        showMessage(data['message']?.toString() ?? 'Đăng nhập thất bại');
      }
    } catch (_) {
      showMessage('Không kết nối được API. Hãy chạy backend trước.');
    } finally {
      if (mounted) setState(() => authLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await signInFirebaseWithGooglePopup();
      return;
    }

    if (!googleReady) {
      showMessage('Google login chưa sẵn sàng.');
      return;
    }

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      showMessage('Trên web hãy bấm nút Google chính thức bên dưới.');
      return;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      await signInFirebaseWithGoogleAccount(account);
    } catch (error) {
      showMessage('Không đăng nhập được Google: $error');
    }
  }

  Future<void> signInFirebaseWithGoogleAccount(
    GoogleSignInAccount account,
  ) async {
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      showMessage('Google không trả về idToken');
      return;
    }

    setState(() => authLoading = true);
    try {
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': firebaseUser?.email ?? account.email,
          'name':
              firebaseUser?.displayName ?? account.displayName ?? account.email,
          'avatar': firebaseUser?.photoURL ?? account.photoUrl ?? '',
          'idToken': await firebaseUser?.getIdToken() ?? idToken,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          currentUser = AppUser.fromJson(data['user']);
          authToken = (data['token'] ?? '').toString();
        });
        await saveSession();
        showMessage('Đăng nhập Google thành công');
      } else {
        showMessage(data['message']?.toString() ?? 'Đăng nhập Google thất bại');
      }
    } catch (_) {
      showMessage('Không kết nối được API Google login');
    } finally {
      if (mounted) setState(() => authLoading = false);
    }
  }

  Future<void> signInFirebaseWithGooglePopup() async {
    setState(() => authLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        GoogleAuthProvider(),
      );
      await syncFirebaseUserWithBackend(userCredential.user);
    } catch (error) {
      showMessage('Không đăng nhập được Google: $error');
    } finally {
      if (mounted) setState(() => authLoading = false);
    }
  }

  Future<void> syncFirebaseUserWithBackend(User? firebaseUser) async {
    if (firebaseUser == null) {
      showMessage('Firebase không trả về thông tin tài khoản');
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ?? firebaseUser.email ?? 'Google User',
        'avatar': firebaseUser.photoURL ?? '',
        'idToken': await firebaseUser.getIdToken(),
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        currentUser = AppUser.fromJson(data['user']);
        authToken = (data['token'] ?? '').toString();
      });
      await saveSession();
      if (currentUser?.role == 'admin') {
        await fetchAdminData();
      } else {
        await fetchOrders();
        await fetchCart();
      }
      showMessage('Đăng nhập Google thành công');
    } else {
      showMessage(data['message']?.toString() ?? 'Đăng nhập Google thất bại');
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await clearSession();
    setState(() {
      currentUser = null;
      authToken = null;
      tabIndex = 0;
    });
  }
}
