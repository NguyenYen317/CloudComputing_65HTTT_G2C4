part of '../../main.dart';

class FeedbackPage extends StatelessWidget {
  final OrderRecord order;
  final AppUser user;

  const FeedbackPage({super.key, required this.order, required this.user});

  @override
  Widget build(BuildContext context) {
    final foodName = order.items.isNotEmpty ? order.items.first.food.name : '';

    final url =
        'https://forms.zohopublic.com/nguyenthiyen31072004gm1/form/FoodFeedbackForm/formperma/pUQFEg4gfZ6Rxv3igAudBjTc1VAa7SPGaEuLxXnDhvM'
        '?customer_name=${Uri.encodeComponent(user.name)}'
        '&customer_email=${Uri.encodeComponent(user.email)}'
        '&food_name=${Uri.encodeComponent(foodName)}'
        '&order_id=${Uri.encodeComponent(order.code)}';

    final viewTypeKey = base64Url.encode(
      utf8.encode('${order.code}-${user.email}-${user.id}'),
    );
    final viewType = 'zoho-feedback-$viewTypeKey';

    // register iframe view for this specific order/user; ignore if already registered
    try {
      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
    } catch (_) {
      // already registered — ignore
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Food Feedback')),
      body: HtmlElementView(viewType: viewType),
    );
  }
}
