import 'dart:io';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/views/meals/favorite_meals.dart';
import 'package:app/models/meal_model.dart';
import 'package:app/widgets/health_rating_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealHomeScreen extends StatefulWidget {
  final MealModel meal;
  final String imageUrl;
  final bool isFavorite;

  MealHomeScreen(
      {required this.meal, required this.imageUrl, this.isFavorite = false});

  @override
  State<MealHomeScreen> createState() => _MealHomeScreenState();
}

class _MealHomeScreenState extends State<MealHomeScreen> {
  final List<String> _fractionValues = ['1/4', '1/3', '1/2', '3/4'];
  final List<double> _fractionValuesNumeric = [0.25, 0.33, 0.5, 0.75];
  String selectedMealType = 'Buổi sáng';

  double _serving = 1;

  TextEditingController _mealNameController = TextEditingController();
  late bool isFavorite;

  String _formatServingValue(double serving) {
    if (serving < 1) {
      int index = _fractionValuesNumeric
          .indexWhere((value) => (value - serving).abs() < 0.01);
      return index != -1 ? _fractionValues[index] : serving.toStringAsFixed(2);
    }
    return serving.toInt().toString();
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
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Nutrition Detail'),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: selectedMealType,
            hint: Text(
              "Chọn buổi",
              style: TextStyle(color: Colors.white),
            ),
            dropdownColor: Colors.blueGrey,
            items: ['Buổi sáng', 'Buổi trưa', 'Buổi tối', 'Ăn vặt']
                .map((type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedMealType = value!;
              });
            },
          ),
        ],
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
            // Save to favorite
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.meal.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Favorite button
                      IconButton(
                        onPressed: () async {
                          if (isFavorite) {
                            await _removeFavoriteMeal();
                          } else {
                            _showSaveMealDialog();
                          }
                        },
                        icon: isFavorite
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(Icons.favorite_border, color: Colors.red),
                      ),
                      // Move to favorite meals screen
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FavoriteMealsScreen()),
                          );
                        },
                        child: Text(
                          "Danh sách yêu thích",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            decorationColor: Colors.blue,
                            decorationThickness: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
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
                                                        ].contains(nutrient
                                                            .name))
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
                    child: _buildIngredients(widget.meal.ingredients, _serving),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("Tổng cộng")),
                        Expanded(
                            child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              "${(widget.meal.weight * _serving).toStringAsFixed(1)} g"),
                        )),
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              "${(widget.meal.calories * _serving).toStringAsFixed(1)} Cal"),
                        )),
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
                          (nutrient) => _buildNutrientRow(
                              nutrient.name, nutrient.amount),
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  child: Text("Thử lại"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await saveMealData(
                      context,
                      widget.meal,
                      widget.imageUrl,
                      _serving,
                      selectedMealType,
                      false, // isFavorite = false -> log meal
                      "", // Log meal without custom name
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.yellow[700],
                  ),
                  child: Text("Lưu vào nhật ký"),
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
          Text('${(amount * _serving).toStringAsFixed(1)} g'),
          // Text((amount * _serving).toString()),
        ],
      ),
    );
  }

  void _checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;

    // Check if the meal is in the favorite list
    var snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('originalName', isEqualTo: widget.meal.name)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isFavorite = true; // Favorite meal
      });
    }
  }

  void _showSaveMealDialog() {
    // Set tên mặc định ban đầu cho món ăn
    _mealNameController.text = widget.meal.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              MediaQuery.of(context).viewInsets, // Đẩy lên khi bàn phím hiện ra
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề
                Text(
                  "Lưu món ăn yêu thích",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Ô nhập tên món ăn
                TextField(
                  controller: _mealNameController,
                  decoration: InputDecoration(
                    labelText: "Đặt tên riêng cho món ăn",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // Nút lưu món ăn
                ElevatedButton(
                  onPressed: () async {
                    if (_mealNameController.text.isNotEmpty) {
                      // Gọi hàm saveMealData để lưu món yêu thích
                      await saveMealData(
                        context,
                        widget.meal, // Dữ liệu món ăn
                        widget.imageUrl, // Ảnh món ăn
                        _serving, // Số lượng khẩu phần
                        "favorite", // Type là favorite
                        true, // isFavorite = true
                        _mealNameController.text, // Tên do user đặt
                      );

                      // Đóng modal
                      Navigator.pop(context);

                      // Cập nhật trạng thái UI
                      setState(() {
                        isFavorite = true;
                      });

                      // Hiển thị thông báo SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Món ăn đã được thêm vào danh sách yêu thích!",
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.green,
                          action: SnackBarAction(
                            label: 'Xem danh sách',
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FavoriteMealsScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      // Thông báo lỗi khi không nhập tên
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Vui lòng nhập tên món ăn!",
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Lưu món ăn"),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> saveMealData(
      BuildContext context,
      dynamic meal,
      String imageUrl,
      double serving,
      String selectedMealType,
      bool isFavorite,
      String customName) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User is not logged in!");
        return;
      }

      String userId = user.uid;
      DateTime now = DateTime.now();

      // Create data for meal
      Map<String, dynamic> mealData = {
        'customName': customName, // User-defined name
        'originalName': meal.name, // Default name
        'calories': meal.calories * serving,
        'weight': meal.weight * serving,
        'nutrients': meal.nutrients
            .map((nutrient) => {
                  'name': nutrient.name,
                  'amount': nutrient.amount * serving,
                })
            .toList(),
        'ingredients': meal.ingredients
            .map((ingredient) => {
                  'nameEn': ingredient.nameEn,
                  'nameVi': ingredient.nameVi,
                  'quantity': ingredient.quantity * serving,
                  'calories': ingredient.calories * serving,
                })
            .toList(),
        'imageUrl': imageUrl,
        'userId': userId,
        'loggedAt': isFavorite
            ? null
            : DateFormat('yyyy-MM-dd')
                .format(now), // Date when the meal is logged
        'type': isFavorite ? 'favorite' : selectedMealType, // Meal type
        'isFavorite': isFavorite,
        'savedAt':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(now), // Date when saved
      };

      // Collection name
      String collectionName = isFavorite ? 'favorite_meals' : 'logged_meals';

      // Add meal data to Firestore
      await FirebaseFirestore.instance.collection(collectionName).add(mealData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Món ăn đã được thêm vào danh sách yêu thích!'
                : 'Món ăn đã được lưu vào nhật ký!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Đã xảy ra lỗi khi thêm món ăn vào danh sách yêu thích!'
                : 'Đã xảy ra lỗi khi lưu món ăn vào nhật ký!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFavoriteMeal() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;

      // Find the favorite meal
      var snapshot = await FirebaseFirestore.instance
          .collection('favorite_meals')
          .where('userId', isEqualTo: userId)
          .where('originalName', isEqualTo: widget.meal.name)
          .get();

      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance
            .collection('favorite_meals')
            .doc(doc.id)
            .delete();
      }

      // Update UI
      setState(() {
        isFavorite = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Món ăn đã được xoá khỏi danh sách yêu thích!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Đã xảy ra lỗi khi xoá món ăn khỏi danh sách yêu thích!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Widget _buildIngredients(List<IngredientModel> ingredients, double serving) {
  return Column(
    children: ingredients.map((ingredient) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(ingredient.nameVi),
          ),
          Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Text("${(ingredient.quantity * serving)} g")),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                  "${(ingredient.calories * serving).toStringAsFixed(1)} Cal"),
            ),
          ),
        ],
      );
    }).toList(),
  );
}

Widget _buildFoodItem(NutritionModel nutrient, {bool isAddMore = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller:
                TextEditingController(text: nutrient.amount.toString()),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
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
