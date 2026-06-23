part of '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AppUser? currentUser;
  String? authToken;
  List<Food> foods = [];
  List<CartItem> cart = [];
  List<OrderRecord> orders = [];
  final Set<String> ratedOrders = {};
  List<AppUser> adminUsers = [];
  List<BigQueryOrderEvent> bigQueryEvents = [];
  MlPredictions? mlPredictions;
  bool loading = true;
  bool authLoading = false;
  bool registering = false;
  bool googleReady = false;
  bool mlLoading = false;
  bool mlActionLoading = false;
  bool bigQueryLoading = false;
  String? bigQueryError;
  String? mlError;
  String? storedCartRaw;
  String selectedCategory = 'Tất cả';
  String selectedDeliveryDistrict = defaultHanoiDistrict;
  String selectedDeliveryWard = defaultHanoiWard;
  String query = '';
  int tabIndex = 0;
  int adminTabIndex = 0;

  @override
  void initState() {
    super.initState();
    loadLocalState();
    fetchFoods();
    initGoogleSignIn();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> markOrderRated(String code) async {
    if (ratedOrders.contains(code)) return;
    ratedOrders.add(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ratedOrders', ratedOrders.toList());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return _buildAuthScreen();
    if (currentUser?.role == 'admin') return _buildAdminScreen();

    return _buildCustomerHomeScreen();
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _parseBigQueryTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();
  if (value is Map && value['value'] != null) {
    return _parseBigQueryTimestamp(value['value']);
  }

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  final match = RegExp(r'value:\s*([^}]+)').firstMatch(text);
  final normalized = (match?.group(1) ?? text).trim();
  final isoText = normalized.endsWith('Z') ? normalized : '${normalized}Z';
  return DateTime.tryParse(isoText)?.toLocal();
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String formatLocalDateTime(DateTime? value) {
  if (value == null) return '-';
  return '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year} '
      '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}:${_twoDigits(value.second)}';
}

String _contentTypeForFileName(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}

const orderStatusLabels = {
  'pending': 'Chờ xác nhận',
  'confirmed': 'Đã xác nhận',
  'preparing': 'Đang chuẩn bị',
  'waiting_shipper': 'Chờ shipper lấy hàng',
  'assigned_shipper': 'Shipper đã nhận đơn',
  'delivering': 'Đang giao',
  'completed': 'Giao thành công',
  'cancelled': 'Đã hủy',
};

String normalizeOrderStatus(String status) {
  if (orderStatusLabels.containsKey(status)) return status;
  final lower = status.toLowerCase();
  if (lower.contains('cancel') ||
      lower.contains('huy') ||
      lower.contains('hủy')) {
    return 'cancelled';
  }
  return 'pending';
}

String orderStatusLabel(String status) {
  return orderStatusLabels[normalizeOrderStatus(status)] ?? 'Chờ xác nhận';
}

Color orderStatusColor(String status) {
  switch (normalizeOrderStatus(status)) {
    case 'completed':
      return Colors.green.shade700;
    case 'cancelled':
      return Colors.grey.shade600;
    case 'delivering':
      return Colors.blue.shade700;
    case 'assigned_shipper':
      return Colors.indigo.shade700;
    default:
      return AppColors.primary;
  }
}

bool isActiveOrder(OrderRecord order) {
  final status = normalizeOrderStatus(order.status);
  return status != 'cancelled';
}

String _imageFor(int id, String image) {
  if (id == 3 && image.contains('1562967916-eb82221dfb36')) {
    return 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&w=500&q=80';
  }
  if (image.isEmpty || image.contains('?')) return image;
  return '$image?auto=format&fit=crop&w=500&q=80';
}

String formatMoney(int value) => CurrencyFormatter.vnd(value);

const demoFoods = [
  Food(
    id: 1,
    name: 'Burger bò phô mai',
    price: 50000,
    originalPrice: 65000,
    image:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80',
    category: 'Burger',
    restaurant: 'Burger House',
    rating: 4.8,
    sold: 210,
    discountPercent: 23,
    tags: ['Freeship', 'Bán chạy', 'Còn nóng'],
  ),
  Food(
    id: 2,
    name: 'Pizza hải sản',
    price: 80000,
    originalPrice: 99000,
    image:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=500&q=80',
    category: 'Pizza',
    restaurant: 'Pizza Corner',
    rating: 4.7,
    sold: 168,
    discountPercent: 19,
    tags: ['Voucher', 'Combo', 'Size M'],
  ),
  Food(
    id: 3,
    name: 'Gà rán giòn cay',
    price: 60000,
    originalPrice: 75000,
    image:
        'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&w=500&q=80',
    category: 'Gà rán',
    restaurant: 'Crispy Chicken',
    rating: 4.9,
    sold: 340,
    discountPercent: 20,
    tags: ['Bán chạy', 'Giòn nóng', 'Deal sốc'],
  ),
];
