// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminBigQueryScreenBuilder on _HomePageState {
  Widget _buildAdminBigQueryEvents() {
    if (bigQueryLoading) {
      return const _AdminNotice(message: 'Đang tải dữ liệu BigQuery...');
    }

    if (bigQueryError != null) {
      return _AdminNotice(message: bigQueryError!);
    }

    if (bigQueryEvents.isEmpty) {
      return const _AdminNotice(
        message:
            'Chưa có dữ liệu BigQuery. Hãy đặt hoặc cập nhật một đơn hàng.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: fetchBigQueryEvents,
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới'),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('eventType')),
              DataColumn(label: Text('orderId')),
              DataColumn(label: Text('userEmail')),
              DataColumn(label: Text('status')),
              DataColumn(label: Text('totalAmount')),
              DataColumn(label: Text('itemCount')),
              DataColumn(label: Text('eventAt')),
            ],
            rows: bigQueryEvents
                .map(
                  (event) => DataRow(
                    cells: [
                      DataCell(Text(event.eventType)),
                      DataCell(Text(event.orderId)),
                      DataCell(Text(event.userEmail)),
                      DataCell(Text(event.status)),
                      DataCell(Text('${event.totalAmount}')),
                      DataCell(Text('${event.itemCount}')),
                      DataCell(Text(formatLocalDateTime(event.eventAt))),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
