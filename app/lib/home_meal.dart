import 'dart:io';

import 'package:app/calorie_tracker_home.dart';
import 'package:app/orther/themes.dart';
import 'package:app/product_scan.dart';
import 'package:app/widgets/health_rating_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'meal.dart';

class MealHomeScreen extends StatefulWidget {
  final Meal meal;
  final String imageUrl;

  MealHomeScreen({required this.meal, required this.imageUrl});

  @override
  State<MealHomeScreen> createState() => _MealHomeScreenState();
}

class _MealHomeScreenState extends State<MealHomeScreen> {
  final List<String> _fractionValues = ['1/4', '1/3', '1/2', '3/4'];
  double _serving = 1; // Giá trị mặc định là 1 serving

  String _formatServingValue(double serving) {
    if (serving < 1) {
      // Với giá trị nhỏ hơn 1, hiển thị theo danh sách fraction
      int index = ((_fractionValues.length) * serving).round() - 1;
      return index >= 0 && index < _fractionValues.length
          ? _fractionValues[index]
          : serving.toStringAsFixed(2);
    }
    return serving.toInt().toString();
  }

  List<Nutrition> _adjustNutrients() {
    return widget.meal.nutrients.map((nutrient) {
      final adjustedAmount = nutrient.amount;
      return Nutrition(
        name: nutrient.name,
        amount: (adjustedAmount * _serving),
      );
    }).toList();
  }

  void _updateServing(bool isIncrement) {
    setState(() {
      if (isIncrement) {
        _serving = _serving < 1 ? _serving + 0.25 : _serving + 1;
      } else {
        if (_serving <= 0.25) return;
        _serving = _serving <= 1 ? _serving - 0.25 : _serving - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Nutrition Detail'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageUrl.startsWith('http'))
              Image.network(
                widget.imageUrl,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Không tải được ảnh mạng'),
              )
            else if (File(widget.imageUrl).existsSync())
              Image.file(File(widget.imageUrl))
            else
              const SizedBox(height: 16.0),

            Text(
              widget.meal.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Nutrition Estimate Table
            Container(
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(132, 141, 185, 66),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nutrition Estimate",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ),
                                              Text(
                                                "Edit",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Code for regenerate action
                                                },
                                                child: Text("Regenerate",
                                                    style: TextStyle(
                                                        color: Colors.green)),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              "Updating the content will use 1 daily use",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: widget.meal.nutrients
                                                    .where((nutrient) => ![
                                                          "Calories",
                                                          "Protein",
                                                          "Total Carbohydrate",
                                                          "Total Fat"
                                                        ].contains(
                                                            nutrient.name))
                                                    .map((nutrient) =>
                                                        _buildFoodItem(
                                                            nutrient))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: SizedBox(child: Icon(Icons.edit))),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Food item",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Weight/Volume",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Calories",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: _buildIngredients(widget.meal.ingredients),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("Tổng cộng")
                        ),
                        Expanded(
                          child: Text(widget.meal.weight)
                        ),
                        Expanded(
                          child: Text("${widget.meal.calories}Cal")
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey),
                  Container(
                    color: Colors.yellow[100],
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nutrient",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        ...widget.meal.nutrients.map(
                          (nutrient) =>
                              _buildNutrientRow(nutrient.name, nutrient.amount),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) {
            //       return CalorieTrackerHome();
            //     }));
            //   },
            //   style: ElevatedButton.styleFrom(
            //     foregroundColor: Colors.white,
            //     backgroundColor: Colors.green,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: Text("Refine Result"),
            // ),
            SizedBox(height: 16),
            HealthRatingWidget(
              healthRating: // Example health rating (75%)
                  (0.3 +
                      (0.7 - 0.3) *
                          (new DateTime.now().millisecondsSinceEpoch % 1000) /
                          1000),
            ),
            SizedBox(height: 16),
            Text(
              "The Amount Eaten (Serving)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => _updateServing(false),
                ),
                Text(
                  _formatServingValue(_serving),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _updateServing(true),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScanScreen()
                  ),
                );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  child: Text("Try another"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        print("User is not logged in!");
                        return;
                      }
                      String userId = user.uid;

                      DateTime now = DateTime.now();

                      Map<String, dynamic> mealData = {
                        'name': widget.meal.name,
                        'calories': widget.meal.calories,
                        'weight': widget.meal.weight,
                        'nutrients': widget.meal.nutrients
                            .map((nutrient) => {
                                  'name': nutrient.name,
                                  'amount': nutrient.amount,
                                })
                            .toList(),
                        'imageUrl': widget.imageUrl,
                        'loggedAt': DateFormat('yyyy-MM-dd').format(now),
                        "userId": userId,
                      };

                      await FirebaseFirestore.instance
                          .collection('logged_meals')
                          .add(mealData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Meal logged successfully!')),
                      );
                    } catch (e) {
                      // Xử lý lỗi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to log meal: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.yellow[700],
                  ),
                  child: Text("Log This Meal"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String nutrient, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text((nutrient)),
          Text(amount.toString()),
        ],
      ),
    );
  }
}

Widget _buildIngredients(List<Ingredient> ingredients) {
  return Column(
    children: ingredients.map((ingredient) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(ingredient.name_vi),
          ),
          Expanded(
            child: Text("${ingredient.quantity}g"),
          ),
          Expanded(
            child: Text("${ingredient.colories}Cal"),
          ),
        ],
      );
    }).toList(),
  );
}

Widget _buildFoodItem(Nutrition nutrient, {bool isAddMore = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: TextEditingController(text: nutrient.amount.toString()),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              // suffixText: nutrient.unit, // Sử dụng đơn vị của nutrient
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: TextField(
            controller: TextEditingController(text: nutrient.name),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: isAddMore ? "Add more food" : null,
            ),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(isAddMore ? Icons.add : Icons.close),
          onPressed: () {
            // Handle add or remove action
          },
        ),
      ],
    ),
  );
}