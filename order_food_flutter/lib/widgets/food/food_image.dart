part of '../../main.dart';

class _FoodImage extends StatelessWidget {
  final String url;
  final double size;

  const _FoodImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: const Color(0xffffefe7),
          child: const Icon(Icons.restaurant),
        ),
      ),
    );
  }
}
