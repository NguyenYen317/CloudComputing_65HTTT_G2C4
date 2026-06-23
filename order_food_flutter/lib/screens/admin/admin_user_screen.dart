// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminUserScreenBuilder on _HomePageState {
  Widget _buildAdminUsers() {
    return Column(
      children: adminUsers
          .map(
            (user) => ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusPill(
                    text: user.role,
                    color: user.role == 'admin'
                        ? const Color(0xffff5a1f)
                        : Colors.grey.shade600,
                  ),
                  if (user.role != 'admin') ...[
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: 'Xóa tài khoản khách',
                      onPressed: () => deleteCustomerUser(user),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
