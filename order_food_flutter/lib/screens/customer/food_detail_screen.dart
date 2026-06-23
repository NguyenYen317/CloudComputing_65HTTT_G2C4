part of '../../main.dart';

class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({super.key, required this.food, required this.onAdd});

  final Food food;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FoodDetailImage(url: food.image),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (food.discountPercent > 0)
                          _StatusPill(text: '-${food.discountPercent}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food.restaurant,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xffffb000),
                          size: 18,
                        ),
                        Text(
                          ' ${food.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 14),
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey.shade700,
                          size: 18,
                        ),
                        Text(' Đã bán ${food.sold}'),
                      ],
                    ),
                    if (food.tags.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: food.tags
                            .map((tag) => _Tag(text: tag))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      food.description.isEmpty
                          ? 'Món ăn đang được cập nhật mô tả.'
                          : food.description,
                      style: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          formatMoney(food.price),
                          style: const TextStyle(
                            color: Color(0xffff5a1f),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (food.originalPrice > food.price)
                          Text(
                            formatMoney(food.originalPrice),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Thêm vào giỏ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodDetailImage extends StatelessWidget {
  const _FoodDetailImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xfffff7f3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffffd8c7)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url.trim().isEmpty
              ? const Center(child: Icon(Icons.restaurant, size: 52))
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.restaurant, size: 52)),
                ),
        ),
      ),
    );
  }
}
