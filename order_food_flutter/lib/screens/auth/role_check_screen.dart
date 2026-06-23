// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AuthRoleCheckScreenBuilder on _HomePageState {
  Widget _buildAuthScreen() {
    return registering ? _buildRegisterScreen() : _buildLoginScreen();
  }

  Widget _buildAuthScaffold({
    required String subtitle,
    required List<Widget> children,
  }) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Order Food',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 18),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
