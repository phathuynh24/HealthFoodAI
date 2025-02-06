class CalorieCalculator {
  static const Map<String, double> activityMultipliers = {
    "Không vận động nhiều": 1.2,
    "Hơi vận động": 1.375,
    "Vận động vừa phải": 1.55,
    "Vận động nhiều": 1.725,
    "Vận động rất nhiều": 1.9
  };

  static const double caloriesPerKg = 7700; // 1 kg ≈ 7700 calories

  /// Tính chỉ số BMR (Basal Metabolic Rate)
  static double calculateBMR(String gender, double weight, int height, int age) {
    if (gender == "Male") {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  /// Tính chỉ số TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(double bmr, String activityLevel) {
    return bmr * (activityMultipliers[activityLevel] ?? 1.2);
  }

  /// Điều chỉnh lượng calo dựa trên mục tiêu và tốc độ thay đổi cân nặng
  static double adjustCalories(double tdee, String goal, double? weightChangeRate) {
    double dailyCalorieAdjustment = 0;
    if (weightChangeRate != null && goal != "Duy trì cân nặng") {
      dailyCalorieAdjustment = (weightChangeRate * caloriesPerKg) / 7;
    }

    if (goal == "Giảm cân") {
      return tdee - dailyCalorieAdjustment;
    } else if (goal == "Tăng cân") {
      return tdee + dailyCalorieAdjustment;
    } else {
      return tdee; // Duy trì cân nặng
    }
  }

  /// Hàm tổng hợp để tính toán lượng calo hàng ngày
  static double calculateDailyCalories({
    required String gender,
    required double weight,
    required int height,
    required int age,
    required String activityLevel,
    required String goal,
    double? weightChangeRate,
  }) {
    double bmr = calculateBMR(gender, weight, height, age);
    double tdee = calculateTDEE(bmr, activityLevel);
    return adjustCalories(tdee, goal, weightChangeRate);
  }
}
