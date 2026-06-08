// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminScreenBuilder on _HomePageState {
  Widget _buildAdminScreen() {
    final tabs = [
      (Icons.dashboard_outlined, 'Dashboard'),
      (Icons.restaurant_menu_outlined, 'Món ăn'),
      (Icons.receipt_long_outlined, 'Đơn hàng'),
      (Icons.people_outline, 'Người dùng'),
      (Icons.payments_outlined, 'Doanh thu'),
      (Icons.trending_up_outlined, 'Bán chạy'),
      (Icons.lightbulb_outline, 'Đề xuất'),
      (Icons.table_chart_outlined, 'BigQuery'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Food Admin',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: fetchAdminData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: adminTabIndex,
            onDestinationSelected: (index) =>
                setState(() => adminTabIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final tab in tabs)
                NavigationRailDestination(
                  icon: Icon(tab.$1),
                  label: Text(tab.$2),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  tabs[adminTabIndex].$2,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _buildAdminTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTab() {
    switch (adminTabIndex) {
      case 0:
        return _buildAdminDashboard();
      case 1:
        return _buildAdminFoods();
      case 2:
        return _buildAdminOrders();
      case 3:
        return _buildAdminUsers();
      case 4:
        return _buildAdminRevenue();
      case 5:
        return _buildAdminBestSellers();
      case 6:
        return _buildAdminSuggestions();
      default:
        return _buildAdminBigQueryEvents();
    }
  }
}
