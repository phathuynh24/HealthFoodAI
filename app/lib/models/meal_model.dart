import 'package:app/core/firebase/firebase_constants.dart';

class MealModel {
  final String id;
  final String name;
  final double weight;
  final double calories;
  final List<NutritionModel> nutrients;
  final List<IngredientModel> ingredients;
  final bool isFavorite;
  final String loggedAt;
  final String savedAt;
  final String type;
  final String userId;
  final String imageUrl;
  final List<dynamic> warnings;
  final double serving;

  MealModel({
    required this.id,
    required this.name,
    required this.weight,
    required this.calories,
    required this.nutrients,
    required this.ingredients,
    required this.isFavorite,
    required this.loggedAt,
    required this.savedAt,
    required this.type,
    required this.userId,
    required this.imageUrl,
    required this.warnings,
    required this.serving,
  });

  /// Map to Model
  factory MealModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return MealModel(
        id: '',
        name: 'Unknown',
        weight: 0,
        calories: 0,
        nutrients: [],
        ingredients: [],
        isFavorite: false,
        loggedAt: '',
        savedAt: '',
        type: '',
        userId: '',
        imageUrl: '',
        warnings: [],
        serving: 1,
      );
    }

    return MealModel(
      id: map[MealFields.id] ?? '',
      name: (map[MealFields.customName] as String?)?.isNotEmpty == true
          ? map[MealFields.customName]
          : map[MealFields.originalName] ?? 'Unnamed Meal',
      weight: (map[MealFields.weight] ?? 0).toDouble(),
      calories: (map[MealFields.calories] ?? 0).toDouble(),
      nutrients: (map[MealFields.nutrients] as List<dynamic>?)
              ?.map((item) =>
                  NutritionModel.fromMap(item as Map<String, dynamic>?))
              .toList() ??
          [],
      ingredients: (map[MealFields.ingredients] as List<dynamic>?)
              ?.map((item) =>
                  IngredientModel.fromMap(item as Map<String, dynamic>?))
              .toList() ??
          [],
      isFavorite: map[MealFields.isFavorite] ?? false,
      loggedAt: map[MealFields.loggedAt] ?? '',
      savedAt: map[MealFields.savedAt] ?? '',
      type: map[MealFields.type] ?? '',
      userId: map[MealFields.userId] ?? '',
      imageUrl: map[MealFields.imageUrl] ?? '',
      warnings: map[MealFields.warnings] ?? [],
      serving: (map[MealFields.serving] ?? 1).toDouble(),
    );
  }

  MealModel copyWith({List<IngredientModel>? newIngredients}) {
    return MealModel(
      id: id,
      name: name,
      weight: weight,
      calories: calories,
      nutrients: nutrients,
      ingredients: newIngredients ?? ingredients,
      warnings: warnings,
      isFavorite: isFavorite,
      loggedAt: loggedAt,
      savedAt: savedAt,
      type: type,
      userId: userId,
      imageUrl: imageUrl,
      serving: serving,
    );
  }
}

/// Ingredients Model
class IngredientModel {
  final String nameEn;
  final String nameVi;
  final double quantity;
  final double calories;

  IngredientModel({
    required this.nameEn,
    required this.nameVi,
    required this.quantity,
    required this.calories,
  });

  factory IngredientModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return IngredientModel(
          nameEn: 'Unknown', nameVi: 'Không rõ', quantity: 0, calories: 0);
    }
    return IngredientModel(
      nameEn: map[IngredientFields.nameEn] ?? 'Unknown',
      nameVi: map[IngredientFields.nameVi] ?? 'Không rõ',
      quantity: (map[IngredientFields.quantity] ?? 0).toDouble(),
      calories: (map[IngredientFields.calories] ?? 0).toDouble(),
    );
  }
}

/// Nutrition Model
class NutritionModel {
  final String name;
  final double amount;

  NutritionModel({required this.name, required this.amount});

  factory NutritionModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return NutritionModel(name: 'Unknown', amount: 0);
    return NutritionModel(
      name: map[NutritionFields.name] ?? 'Unknown',
      amount: (map[NutritionFields.amount] ?? 0).toDouble(),
    );
  }
}
