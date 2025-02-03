import 'package:app/views/home/home_screen.dart';
import 'package:flutter/material.dart';

class CaloriePlanScreen extends StatelessWidget {
  final String gender;
  final int height;
  final double weight;
  final int age;
  final double targetWeight;
  final String activityLevel;
  final String goal;

  const CaloriePlanScreen({
    super.key,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.targetWeight,
    required this.activityLevel,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final double bmr = calculateBMR();
    final double tdee = calculateTDEE(bmr);
    final double adjustedCalories = adjustCalories(tdee);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.green[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Tiêu đề
            const Text(
              "Your personalized meal plan is ready",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Tổng calo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "Total Calories",
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    ],
                  ),
                  Text(
                    "${adjustedCalories.toStringAsFixed(0)} Cal",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách các bữa ăn (tạm thời để trống)
            Expanded(
              child: ListView(
                children: [
                  buildMealItem("Breakfast", "", ""),
                  buildMealItem("Lunch", "", ""),
                  buildMealItem("Dinner", "", ""),
                  buildMealItem("Snacks", "", ""),
                ],
              ),
            ),

            // Nút Finish
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Finish",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tính BMR
  double calculateBMR() {
    if (gender == "Male") {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  // Tính TDEE
  double calculateTDEE(double bmr) {
    double multiplier;
    switch (activityLevel) {
      case "Not Active":
        multiplier = 1;
        break;
      case "Somewhat Active":
        multiplier = 1.375;
        break;
      case "Moderately Active":
        multiplier = 1.55;
        break;
      case "Highly Active":
        multiplier = 1.725;
        break;
      case "Extremely Active":
        multiplier = 1.9;
        break;
      default: // Ít vận động
        multiplier = 1.2;
    }
    return bmr * multiplier;
  }

  // Điều chỉnh calo theo mục tiêu
  double adjustCalories(double tdee) {
    if (goal == "Lose Weight") {
      return tdee - 500;
    } else if (goal == "Gain Weight") {
      return tdee + 500;
    } else {
      return tdee;
    }
  }

  // Widget cho từng bữa ăn
  Widget buildMealItem(String title, String food, String calories) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.fastfood, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(food.isEmpty ? "To be decided" : food),
              ],
            ),
          ),
          Text(calories.isEmpty ? "" : "$calories Cal"),
        ],
      ),
    );
  }
}
