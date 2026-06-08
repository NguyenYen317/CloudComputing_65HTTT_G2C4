part of '../../main.dart';

class _PriceRow extends StatelessWidget {
  final String label;
  final int value;
  final bool strong;

  const _PriceRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: strong ? 17 : 14,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            formatMoney(value),
            style: TextStyle(
              fontSize: strong ? 18 : 14,
              color: strong ? const Color(0xffff5a1f) : null,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
