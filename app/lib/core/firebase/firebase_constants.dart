class FirebaseConstants {
  /// Collection: Users
  static const String usersCollection = "users";

  /// Collection: Logged Meals
  static const String loggedMealsCollection = "logged_meals";

  /// Collection: Favorite Meals
  static const String favoriteMealsCollection = "favorite_meals";
}

/// Fields of Users
class UserFields {
  static const String uid = "uid";
  static const String email = "email";
  static const String fullName = "fullName";
  static const String gender = "gender";
  static const String age = "age";
  static const String height = "height";
  static const String weight = "weight";
  static const String targetWeight = "targetWeight";
  static const String activityLevel = "activityLevel";
  static const String goal = "goal";
  static const String calories = "calories";
  static const String isFirstLogin = "isFirstLogin";
  static const String status = "status";
  static const String createdAt = "createdAt";
  static const String updatedAt = "updatedAt";
  static const String surveyHistory = "surveyHistory";
  static const String timestamp = "timestamp";
  static const String weightChangeRate = "weightChangeRate";
  static const String weightHistory = "weightHistory";
  static const String weightHistoryDate = "date";
  static const String weightHistoryValue = "value";
}

/// Fields of Logged Meals
class MealFields {
  static const String customName = "customName";
  static const String originalName = "originalName";
  static const String weight = "weight";
  static const String calories = "calories";
  static const String nutrients = "nutrients";
  static const String ingredients = "ingredients";
  static const String warnings = "warnings";
  static const String isFavorite = "isFavorite";
  static const String loggedAt = "loggedAt";
  static const String savedAt = "savedAt";
  static const String type = "type";
  static const String userId = "userId";
  static const String imageUrl = "imageUrl";
  static const String serving = "serving";

  // Fields for Food Scan
  static const String description = "description"; // Description of the meal
  static const String bloodSugar = "blood_sugar"; // Đường huyết
  static const String bloodPressure =
      "blood_pressure"; // Huyết áp (JSON: systolic, diastolic)
  static const String predictedName = "name"; // Name of the meal
  static const String servingWeight =
      "serving_weight_grams"; // Weight of the meal
}

/// Fields of Nutrients
class NutritionFields {
  static const String name = "name";
  static const String amount = "amount";

  // Nutrient names
  static const String protein = "protein";
  static const String totalCarbs = "total_carbohydrate";
  static const String totalFat = "total_fat";
}

/// Fields of Ingredients
class IngredientFields {
  static const String nameEn = "name_en";
  static const String nameVi = "name_vi";
  static const String nameEnglish = "name_english";
  static const String nameVietnamese = "name_vietnamese";
  static const String quantity = "quantity";
  static const String calories = "calories";

  // Ingredient names
  static const String detailedIngredients = "detailed_nutrition";
}
