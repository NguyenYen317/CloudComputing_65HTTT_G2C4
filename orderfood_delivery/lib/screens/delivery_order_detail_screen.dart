import 'package:flutter/material.dart';

import '../config/maps_config.dart';
import '../models/delivery_order_model.dart';
import '../services/maps_service.dart';
import '../services/shipper_service.dart';
import '../widgets/google_map_view.dart';
import '../widgets/status_badge.dart';

class DeliveryOrderDetailScreen extends StatefulWidget {
  const DeliveryOrderDetailScreen({super.key, required this.order});

  final DeliveryOrderModel order;

  @override
  State<DeliveryOrderDetailScreen> createState() =>
      _DeliveryOrderDetailScreenState();
}

class _DeliveryOrderDetailScreenState extends State<DeliveryOrderDetailScreen> {
  final _shipperService = ShipperService();
  final _mapsService = const MapsService();
  late Future<DeliveryOrderModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _shipperService.getOrderDetail(widget.order.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeliveryOrderModel>(
      future: _detailFuture,
      initialData: widget.order,
      builder: (context, snapshot) {
        final order = snapshot.data ?? widget.order;
        return Scaffold(
          appBar: AppBar(title: Text('Đơn ${order.orderId}')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                const LinearProgressIndicator(minHeight: 2),
              if (snapshot.hasError)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _WarningBox(
                    message:
                        'Không tải được dữ liệu bản đồ mới nhất. Vẫn hiển thị thông tin đơn hiện có.',
                  ),
                ),
              _OrderInfoCard(order: order),
              const SizedBox(height: 14),
              _MapCard(order: order, mapsService: _mapsService),
            ],
          ),
        );
      },
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});

  final DeliveryOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Đơn ${order.orderId}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const Divider(height: 28),
            _DetailLine(label: 'Khách hàng', value: order.customerName),
            _DetailLine(label: 'Email', value: order.userEmail),
            _DetailLine(label: 'Số điện thoại', value: order.phone),
            _DetailLine(
              label: 'Địa chỉ',
              value: order.customerAddressOrAddress,
            ),
            _DetailLine(label: 'Ghi chú', value: order.note),
            _DetailLine(
              label: 'Tạo lúc',
              value: _formatVietnamTime(order.createdAt),
            ),
            _DetailLine(
              label: 'Cập nhật',
              value: _formatVietnamTime(order.updatedAt),
            ),
            const Divider(height: 28),
            const Text(
              'Món ăn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...order.items.map(_buildItem),
            const Divider(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tổng tiền',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  _formatMoney(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff0f766e),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(dynamic item) {
    if (item is! Map) return Text(item.toString());

    final name = item['name'] ?? item['foodName'] ?? 'Món ăn';
    final quantity = item['quantity'] ?? 1;
    final price = NumberParser.toInt(item['price']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text('$name x$quantity')),
          if (price > 0) Text(_formatMoney(price)),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.order, required this.mapsService});

  final DeliveryOrderModel order;
  final MapsService mapsService;

  @override
  Widget build(BuildContext context) {
    final directionsUrl = mapsService.buildDirectionsUrl(
      originLat: order.storeLat ?? MapsConfig.defaultStoreLat,
      originLng: order.storeLng ?? MapsConfig.defaultStoreLng,
      destinationLat: order.customerLat,
      destinationLng: order.customerLng,
      destinationAddress: order.customerAddressOrAddress,
    );

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bản đồ giao hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            _DetailLine(
              label: 'Xuất phát',
              value: 'Vị trí hiện tại của shipper',
            ),
            _DetailLine(
              label: 'Giao đến',
              value: order.customerAddressOrAddress,
            ),
            const SizedBox(height: 10),
            GoogleMapView(
              storeLat: order.storeLat ?? MapsConfig.defaultStoreLat,
              storeLng: order.storeLng ?? MapsConfig.defaultStoreLng,
              customerLat: order.customerLat,
              customerLng: order.customerLng,
              customerAddress: order.customerAddressOrAddress,
              directionsUrl: directionsUrl,
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xfffff7ed),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffffd7aa)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xffc2410c)),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _formatMoney(int value) {
  final text = value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return '$textđ';
}

String _formatVietnamTime(String value) {
  if (value.trim().isEmpty) return '';

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;

  final vietnamTime = parsed.toUtc().add(const Duration(hours: 7));
  return '${_twoDigits(vietnamTime.day)}/'
      '${_twoDigits(vietnamTime.month)}/'
      '${vietnamTime.year} '
      '${_twoDigits(vietnamTime.hour)}:'
      '${_twoDigits(vietnamTime.minute)}:'
      '${_twoDigits(vietnamTime.second)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
