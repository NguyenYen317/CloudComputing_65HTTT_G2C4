part of '../../main.dart';

class CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const CartTile({
    super.key,
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          _FoodImage(url: item.food.image, size: 64),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(formatMoney(item.food.price)),
              ],
            ),
          ),
          IconButton.outlined(
            tooltip: 'Giảm',
            onPressed: onDecrease,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          IconButton.filled(
            tooltip: 'Tăng',
            onPressed: onIncrease,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
