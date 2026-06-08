// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension CheckoutScreenBuilder on _HomePageState {
  Widget _buildCheckoutSection() {
    return Column(
      children: [
        _AuthField(
          controller: _addressController,
          label: 'Địa chỉ giao hàng',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 10),
        _AuthField(
          controller: _noteController,
          label: 'Ghi chú cho quán',
          icon: Icons.edit_note_outlined,
        ),
        const SizedBox(height: 14),
        _PriceRow(label: 'Tạm tính', value: subtotal),
        _PriceRow(label: 'Phí giao hàng', value: shippingFee),
        _PriceRow(label: 'Voucher', value: -voucherDiscount),
        const Divider(height: 24),
        _PriceRow(label: 'Tổng thanh toán', value: totalPrice, strong: true),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: orderFood,
          icon: const Icon(Icons.payments_outlined),
          label: const Text('Đặt món ngay'),
        ),
      ],
    );
  }
}
