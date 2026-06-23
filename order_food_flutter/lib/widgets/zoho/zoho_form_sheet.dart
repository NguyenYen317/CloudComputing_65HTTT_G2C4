part of '../../main.dart';

const String zohoFormUrl =
    'https://forms.zohopublic.com/nguyenthiyen31072004gm1/form/FoodFeedbackForm/formperma/pUQFEg4gfZ6Rxv3igAudBjTc1VAa7SPGaEuLxXnDhvM';

Future<void> showZohoFormInApp(
  BuildContext context,
  OrderRecord order,
  VoidCallback onSubmitted, {
  String customerName = '',
  String customerEmail = '',
}) async {
  // Navigate to FeedbackPage which contains the embedded Zoho iframe for web
  // Navigate to FeedbackPage which contains the embedded Zoho iframe for web
  final user = AppUser(id: '', name: customerName, email: customerEmail);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FeedbackPage(order: order, user: user),
    ),
  );
}
