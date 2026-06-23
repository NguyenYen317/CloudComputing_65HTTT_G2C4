import 'package:flutter_test/flutter_test.dart';
import 'package:order_food_flutter/main.dart';

void main() {
  testWidgets('shows the order food home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OrderFoodApp());
    await tester.pump();

    expect(find.text('Order Food'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Giỏ hàng'), findsOneWidget);
    expect(find.text('Đơn hàng'), findsOneWidget);
  });
}
