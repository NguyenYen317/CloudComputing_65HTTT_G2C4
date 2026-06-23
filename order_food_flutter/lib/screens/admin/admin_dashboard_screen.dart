// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminDashboardScreenBuilder on _HomePageState {
  Widget _buildAdminDashboard() {
    final activeOrders = orders.where(isActiveOrder).toList();
    final revenue = activeOrders.fold(0, (total, order) => total + order.total);
    final revenuePrediction = mlPredictions?.revenuePrediction;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _AdminMetric(
          title: 'Tổng đơn',
          value: '${orders.length}',
          icon: Icons.receipt_long,
        ),
        _AdminMetric(
          title: 'Chờ xác nhận',
          value:
              "${orders.where((o) => normalizeOrderStatus(o.status) == 'pending').length}",
          icon: Icons.pending_actions,
        ),
        _AdminMetric(
          title: 'Người dùng',
          value: '${adminUsers.length}',
          icon: Icons.people,
        ),
        _AdminMetric(
          title: 'Doanh thu',
          value: formatMoney(revenue),
          icon: Icons.payments,
        ),
        _buildMlControls(),
        if (revenuePrediction != null)
          _AdminMetric(
            title: 'Dự đoán ngày mai',
            value: formatMoney(revenuePrediction.tomorrow),
            icon: Icons.insights,
          ),
        if (revenuePrediction != null)
          _AdminMetric(
            title: 'Dự đoán 7 ngày',
            value: formatMoney(revenuePrediction.next7Days),
            icon: Icons.trending_up,
          ),
        if (mlLoading)
          const _AdminNotice(message: 'Đang tải dữ liệu Machine Learning...'),
        if (mlError != null) _AdminNotice(message: mlError!),
      ],
    );
  }
}
