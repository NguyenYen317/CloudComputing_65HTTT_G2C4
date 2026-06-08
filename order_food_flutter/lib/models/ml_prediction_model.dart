part of '../main.dart';

class BestSellingFoodPrediction {
  const BestSellingFoodPrediction({
    required this.foodName,
    required this.predictedQuantity,
    required this.level,
  });

  final String foodName;
  final int predictedQuantity;
  final String level;

  factory BestSellingFoodPrediction.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    return BestSellingFoodPrediction(
      foodName: (data['foodName'] ?? '').toString(),
      predictedQuantity: _asInt(data['predictedQuantity']),
      level: (data['level'] ?? '').toString(),
    );
  }
}

class RevenuePrediction {
  const RevenuePrediction({required this.tomorrow, required this.next7Days});

  final int tomorrow;
  final int next7Days;

  factory RevenuePrediction.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    return RevenuePrediction(
      tomorrow: _asInt(data['tomorrow']),
      next7Days: _asInt(data['next7Days']),
    );
  }
}

class MlPredictions {
  const MlPredictions({
    required this.bestSellingFoods,
    required this.revenuePrediction,
    required this.suggestions,
    this.updatedAt = '',
  });

  final List<BestSellingFoodPrediction> bestSellingFoods;
  final RevenuePrediction revenuePrediction;
  final List<String> suggestions;
  final String updatedAt;

  factory MlPredictions.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    return MlPredictions(
      bestSellingFoods: ((data['bestSellingFoods'] as List?) ?? const [])
          .map(BestSellingFoodPrediction.fromJson)
          .toList(),
      revenuePrediction: RevenuePrediction.fromJson(
        data['revenuePrediction'] ?? const {'tomorrow': 0, 'next7Days': 0},
      ),
      suggestions: ((data['suggestions'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(),
      updatedAt: (data['updatedAt'] ?? '').toString(),
    );
  }
}
