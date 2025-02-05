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
}

/// Fields of Nutrients
class NutritionFields {
  static const String name = "name";
  static const String amount = "amount";
}

/// Fields of Ingredients
class IngredientFields {
  static const String nameEn = "name_en";
  static const String nameVi = "name_vi";
  static const String quantity = "quantity";
  static const String calories = "calories";
}
