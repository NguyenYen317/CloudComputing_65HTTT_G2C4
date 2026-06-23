// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension LoginScreenBuilder on _HomePageState {
  Widget _buildLoginScreen() {
    return _buildAuthScaffold(
      subtitle: 'Đăng nhập để tiếp tục đặt món.',
      children: [
        _AuthField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 10),
        _AuthField(
          controller: _passwordController,
          label: 'Mật khẩu',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: authLoading ? null : submitEmailAuth,
          child: const Text('Đăng nhập'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: authLoading ? null : signInWithGoogle,
          icon: const Icon(Icons.login),
          label: const Text('Đăng nhập bằng Google'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => registering = true),
          child: const Text('Chưa có tài khoản? Đăng ký'),
        ),
        if (!kIsWeb && !googleReady)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Google login cần OAuth Client ID thật. Hãy sửa meta trong web/index.html hoặc chạy với --dart-define=GOOGLE_CLIENT_ID=...',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}
