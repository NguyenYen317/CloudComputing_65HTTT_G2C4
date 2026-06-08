part of '../../main.dart';

class _SuggestionTile extends StatelessWidget {
  final String title;
  final String message;

  const _SuggestionTile({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        leading: const Icon(Icons.lightbulb_outline, color: Color(0xffff5a1f)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(message),
      ),
    );
  }
}
