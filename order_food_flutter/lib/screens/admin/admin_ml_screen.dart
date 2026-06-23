// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../../main.dart';

extension AdminMlScreenBuilder on _HomePageState {
  Widget _buildMlControls() {
    final updatedAt = mlPredictions?.updatedAt ?? '';
    final updatedAtLabel = formatLocalDateTime(
      _parseBigQueryTimestamp(updatedAt),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Machine Learning',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: mlActionLoading ? null : trainMlModel,
                icon: mlActionLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.model_training),
                label: const Text('Huấn luyện lại model'),
              ),
              OutlinedButton.icon(
                onPressed: mlActionLoading ? null : updateMlPredictions,
                icon: const Icon(Icons.auto_graph),
                label: const Text('Cập nhật dự đoán ML'),
              ),
            ],
          ),
          if (updatedAt.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Cập nhật lần cuối: $updatedAtLabel'),
          ],
        ],
      ),
    );
  }
}
