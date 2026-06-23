// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminRevenueScreenBuilder on _HomePageState {
  Widget _buildAdminRevenue() {
    final paidOrders = orders.where(isActiveOrder).toList();
    final revenue = paidOrders.fold(0, (total, order) => total + order.total);
    final revenuePrediction = mlPredictions?.revenuePrediction;
    if (revenuePrediction != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdminMetric(
            title: 'Doanh thu tạm tính',
            value: formatMoney(revenue),
            icon: Icons.payments,
          ),
          const SizedBox(height: 12),
          Text('Tính trên ${paidOrders.length} đơn chưa hủy.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _AdminMetric(
                title: 'ML ngày mai',
                value: formatMoney(revenuePrediction.tomorrow),
                icon: Icons.auto_graph,
              ),
              _AdminMetric(
                title: 'ML 7 ngày tới',
                value: formatMoney(revenuePrediction.next7Days),
                icon: Icons.query_stats,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminMetric(
          title: 'Doanh thu tạm tính',
          value: formatMoney(revenue),
          icon: Icons.payments,
        ),
        const SizedBox(height: 12),
        Text('Tính trên ${paidOrders.length} đơn chưa hủy.'),
      ],
    );
  }
}
