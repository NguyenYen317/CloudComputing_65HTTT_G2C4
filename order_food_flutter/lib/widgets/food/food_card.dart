part of '../../main.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const FoodCard({
    super.key,
    required this.food,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FoodImage(url: food.image, size: 96),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (food.discountPercent > 0)
                            _StatusPill(text: '-${food.discountPercent}%'),
                        ],
                      ),
                      Text(
                        food.restaurant,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xffffb000),
                            size: 16,
                          ),
                          Text(
                            ' ${food.rating.toStringAsFixed(1)}  |  Đã bán ${food.sold}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: food.tags
                            .take(3)
                            .map((tag) => _Tag(text: tag))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            formatMoney(food.price),
                            style: const TextStyle(
                              color: Color(0xffff5a1f),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (food.originalPrice > food.price)
                            Text(
                              formatMoney(food.originalPrice),
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          const Spacer(),
                          IconButton.filled(
                            tooltip: 'Thêm vào giỏ',
                            onPressed: onAdd,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
