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

  Map<String, dynamic> toJson() => {
        "name": name,
        "weight": weight,
        "calories": calories,
        "nutrients": nutrients.map((e) => e.toJson()).toList(),
        "ingredients": ingredients.map((e) => e.toJson()).toList(),
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        name: json["name"],
        weight: json["weight"],
        calories: json["calories"],
        nutrients: (json["nutrients"] as List)
            .map((e) => Nutrition.fromJson(e))
            .toList(),
        ingredients: (json["ingredients"] as List)
            .map((e) => Ingredient.fromJson(e))
            .toList(),
      );
}

class Ingredient {
  final String nameEn;
  final String nameVi;
  final double quantity;
  final double calories;

  Ingredient({
    required this.nameEn,
    required this.nameVi,
    required this.quantity,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
        "nameEn": nameEn,
        "nameVi": nameVi,
        "quantity": quantity,
        "calories": calories,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        nameEn: json["nameEn"],
        nameVi: json["nameVi"],
        quantity: json["quantity"],
        calories: json["calories"],
      );
}

class Nutrition {
  final String nutrientName;
  final double nutrientValue;

  Nutrition({
    required this.nutrientName,
    required this.nutrientValue,
  });

  Map<String, dynamic> toJson() => {
        "nutrientName": nutrientName,
        "nutrientValue": nutrientValue,
      };

  factory Nutrition.fromJson(Map<String, dynamic> json) => Nutrition(
        nutrientName: json["nutrientName"],
        nutrientValue: json["nutrientValue"],
      );
}
