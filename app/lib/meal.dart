// meal.dart
class Meal {
  final String name;
  final double weight;
  final double calories;
  final List<Nutrition> nutrients;
  final List<Ingredient> ingredients;

  Meal({
    required this.name,
    required this.weight,
    required this.calories,
    required this.nutrients,
    required this.ingredients,
  });
}

class Ingredient {
  final String name_en;
  final String name_vi;
  final double quantity;
  final double calories;

  Ingredient({
    required this.name_en,
    required this.name_vi,
    required this.quantity,
    required this.calories,
  });
}

class Nutrition {
  final String name;
  final double amount;

  Nutrition({
    required this.name,
    required this.amount,
  });
}