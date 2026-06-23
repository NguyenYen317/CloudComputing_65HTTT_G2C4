// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension CartScreenBuilder on _HomePageState {
  Widget _buildCartTab() {
    if (cart.isEmpty) {
      return const _EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Giỏ hàng đang trống',
        message: 'Chọn món ở trang chủ để bắt đầu đặt hàng.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        const Text(
          'Giỏ hàng',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...cart.map(
          (item) => CartTile(
            item: item,
            onDecrease: () => changeQuantity(item.food, -1),
            onIncrease: () => changeQuantity(item.food, 1),
          ),
        ),
        const SizedBox(height: 14),
        _buildCheckoutSection(),
      ],
    );
  }
}
