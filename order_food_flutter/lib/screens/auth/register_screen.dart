// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension RegisterScreenBuilder on _HomePageState {
  Widget _buildRegisterScreen() {
    return _buildAuthScaffold(
      subtitle: 'Tạo tài khoản để đặt món nhanh hơn.',
      children: [
        _AuthField(
          controller: _nameController,
          label: 'Họ tên',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 10),
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
          child: const Text('Đăng ký'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => registering = false),
          child: const Text('Đã có tài khoản? Đăng nhập'),
        ),
      ],
    );
  }
}
