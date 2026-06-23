// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension CustomerHomeScreenBuilder on _HomePageState {
  Widget _buildCustomerHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Food',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại dữ liệu',
            onPressed: loading ? null : refreshCustomerData,
            icon: const Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: Text(currentUser!.name)),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                tooltip: 'Giỏ hàng',
                onPressed: () => openCustomerTab(1),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (totalItems > 0)
                Positioned(
                  right: 7,
                  top: 7,
                  child: _CountBadge(count: totalItems),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: tabIndex,
              children: [_buildShopTab(), _buildCartTab(), _buildOrdersTab()],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: openCustomerTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Giỏ hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Đơn hàng',
          ),
        ],
      ),
    );
  }

  Future<void> refreshCustomerData() async {
    setState(() => loading = true);
    await fetchFoods();
    await fetchOrders();
    if (!mounted) return;
    showMessage('Đã tải lại dữ liệu');
  }
}
