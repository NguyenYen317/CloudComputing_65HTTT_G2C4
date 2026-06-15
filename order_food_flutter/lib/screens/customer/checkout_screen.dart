// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

const Map<String, List<String>> hanoiDistrictWards = {
  'Ba Đình': [
    'Phúc Xá',
    'Trúc Bạch',
    'Vĩnh Phúc',
    'Cống Vị',
    'Liễu Giai',
    'Nguyễn Trung Trực',
    'Quán Thánh',
    'Ngọc Hà',
    'Điện Biên',
    'Đội Cấn',
    'Kim Mã',
    'Giảng Võ',
    'Thành Công',
  ],
  'Hoàn Kiếm': [
    'Phúc Tân',
    'Đồng Xuân',
    'Hàng Mã',
    'Hàng Buồm',
    'Hàng Đào',
    'Hàng Bạc',
    'Hàng Gai',
    'Chương Dương',
    'Cửa Đông',
    'Lý Thái Tổ',
    'Tràng Tiền',
    'Hàng Bài',
  ],
  'Đống Đa': [
    'Cát Linh',
    'Văn Miếu',
    'Quốc Tử Giám',
    'Láng Thượng',
    'Ô Chợ Dừa',
    'Văn Chương',
    'Hàng Bột',
    'Láng Hạ',
    'Khâm Thiên',
    'Thổ Quan',
    'Nam Đồng',
    'Trung Phụng',
    'Quang Trung',
    'Trung Liệt',
    'Phương Liên',
    'Phương Mai',
    'Ngã Tư Sở',
    'Khương Thượng',
    'Trung Tự',
    'Kim Liên',
  ],
  'Hai Bà Trưng': [
    'Nguyễn Du',
    'Bạch Đằng',
    'Phạm Đình Hổ',
    'Bùi Thị Xuân',
    'Ngô Thì Nhậm',
    'Đồng Nhân',
    'Bách Khoa',
    'Thanh Nhàn',
    'Quỳnh Mai',
    'Quỳnh Lôi',
    'Minh Khai',
    'Vĩnh Tuy',
    'Đồng Tâm',
    'Trương Định',
  ],
  'Cầu Giấy': [
    'Dịch Vọng',
    'Dịch Vọng Hậu',
    'Mai Dịch',
    'Nghĩa Đô',
    'Nghĩa Tân',
    'Quan Hoa',
    'Trung Hòa',
    'Yên Hòa',
  ],
  'Thanh Xuân': [
    'Hạ Đình',
    'Khương Đình',
    'Khương Mai',
    'Khương Trung',
    'Kim Giang',
    'Nhân Chính',
    'Phương Liệt',
    'Thanh Xuân Bắc',
    'Thanh Xuân Nam',
    'Thanh Xuân Trung',
    'Thượng Đình',
  ],
  'Hoàng Mai': [
    'Đại Kim',
    'Định Công',
    'Giáp Bát',
    'Hoàng Liệt',
    'Hoàng Văn Thụ',
    'Lĩnh Nam',
    'Mai Động',
    'Tân Mai',
    'Thanh Trì',
    'Thịnh Liệt',
    'Trần Phú',
    'Tương Mai',
    'Vĩnh Hưng',
    'Yên Sở',
  ],
  'Long Biên': [
    'Bồ Đề',
    'Cự Khối',
    'Đức Giang',
    'Gia Thụy',
    'Giang Biên',
    'Long Biên',
    'Ngọc Lâm',
    'Ngọc Thụy',
    'Phúc Đồng',
    'Phúc Lợi',
    'Sài Đồng',
    'Thạch Bàn',
    'Thượng Thanh',
    'Việt Hưng',
  ],
  'Tây Hồ': [
    'Bưởi',
    'Nhật Tân',
    'Phú Thượng',
    'Quảng An',
    'Thụy Khuê',
    'Tứ Liên',
    'Xuân La',
    'Yên Phụ',
  ],
  'Nam Từ Liêm': [
    'Cầu Diễn',
    'Đại Mỗ',
    'Mễ Trì',
    'Mỹ Đình 1',
    'Mỹ Đình 2',
    'Phú Đô',
    'Phương Canh',
    'Tây Mỗ',
    'Trung Văn',
    'Xuân Phương',
  ],
  'Bắc Từ Liêm': [
    'Cổ Nhuế 1',
    'Cổ Nhuế 2',
    'Đông Ngạc',
    'Đức Thắng',
    'Liên Mạc',
    'Minh Khai',
    'Phú Diễn',
    'Phúc Diễn',
    'Tây Tựu',
    'Thượng Cát',
    'Thụy Phương',
    'Xuân Đỉnh',
    'Xuân Tảo',
  ],
  'Hà Đông': [
    'Biên Giang',
    'Dương Nội',
    'Đồng Mai',
    'Hà Cầu',
    'Kiến Hưng',
    'La Khê',
    'Mộ Lao',
    'Nguyễn Trãi',
    'Phú La',
    'Phú Lãm',
    'Phú Lương',
    'Phúc La',
    'Quang Trung',
    'Vạn Phúc',
    'Văn Quán',
    'Yên Nghĩa',
    'Yết Kiêu',
  ],
};

const defaultHanoiDistrict = 'Hoàng Mai';
const defaultHanoiWard = 'Giáp Bát';

List<String> hanoiWardsForDistrict(String district) =>
    hanoiDistrictWards[district] ?? hanoiDistrictWards[defaultHanoiDistrict]!;

String buildHanoiDeliveryAddress({
  required String street,
  required String ward,
  required String district,
}) {
  final normalizedStreet = street.trim();
  return '$normalizedStreet, $ward, $district, Hà Nội';
}

extension CheckoutScreenBuilder on _HomePageState {
  Widget _buildCheckoutSection() {
    final wards = hanoiWardsForDistrict(selectedDeliveryDistrict);

    return Column(
      children: [
        _AddressDropdown(
          value: selectedDeliveryDistrict,
          label: 'Quận/Huyện',
          icon: Icons.location_city_outlined,
          items: hanoiDistrictWards.keys.toList(),
          onChanged: (value) {
            if (value == null || value == selectedDeliveryDistrict) return;
            setState(() {
              selectedDeliveryDistrict = value;
              selectedDeliveryWard = hanoiWardsForDistrict(value).first;
            });
          },
        ),
        const SizedBox(height: 10),
        _AddressDropdown(
          value: selectedDeliveryWard,
          label: 'Phường/Xã',
          icon: Icons.map_outlined,
          items: wards,
          onChanged: (value) {
            if (value == null) return;
            setState(() => selectedDeliveryWard = value);
          },
        ),
        const SizedBox(height: 10),
        _AuthField(
          controller: _addressController,
          label: 'Số nhà và tên đường',
          icon: Icons.home_work_outlined,
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

class _AddressDropdown extends StatelessWidget {
  const _AddressDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final String label;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xfff1ebe6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffded2ca)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffff5a1f), width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffded2ca)),
        ),
      ),
    );
  }
}
