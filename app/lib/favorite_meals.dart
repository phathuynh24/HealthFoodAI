import 'package:app/home_meal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'meal.dart';

class FavoriteMealsScreen extends StatefulWidget {
  @override
  _FavoriteMealsScreenState createState() => _FavoriteMealsScreenState();
}

class _FavoriteMealsScreenState extends State<FavoriteMealsScreen> {
  // Remove a meal from favorite list
  Future<void> _deleteFavoriteMeal(String docId) async {
    await FirebaseFirestore.instance
        .collection('favorite_meals')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Đã xoá món ăn khỏi danh sách yêu thích!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent),
    );
  }

  // Edit meal name
  Future<void> _editMealName(String docId, String currentName) async {
    TextEditingController _nameController =
        TextEditingController(text: currentName);

    // Show dialog to edit meal name
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chỉnh sửa tên món ăn"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Tên mới",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('favorite_meals')
                      .doc(docId)
                      .update({'customName': _nameController.text});
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Tên món ăn đã được cập nhật!",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.greenAccent,
                    ),
                  );
                }
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh Sách Yêu Thích"), // Screen title
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Get favorite meals from Firestore
        stream: FirebaseFirestore.instance
            .collection('favorite_meals')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
                child:
                    Text("Đã xảy ra lỗi khi tải dữ liệu! Vui lòng thử lại."));
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Chưa có món ăn yêu thích nào!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Data loaded
          final meals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              final docId = meal.id;
              final name = meal['customName'] ?? meal['originalName'];
              final calories = (meal['calories'] as num?)?.toDouble() ?? 0.0;
              final weight = (meal['weight'] as num?)?.toDouble() ?? 0.0;
              final imageUrl = meal['imageUrl'] ?? "";

              // Convert nutrients and ingredients to list of objects
              List<Nutrition> nutrients = (meal['nutrients'] as List<dynamic>?)
                      ?.map((n) => Nutrition(
                            name: n['name'] ?? "",
                            amount: (n['amount'] as num?)?.toDouble() ?? 0.0,
                          ))
                      .toList() ??
                  [];

              List<Ingredient> ingredients =
                  (meal['ingredients'] as List<dynamic>?)
                          ?.map((i) => Ingredient(
                                name_en: i['name_en'] ?? "",
                                name_vi: i['name_vi'] ?? "",
                                quantity:
                                    (i['quantity'] as num?)?.toDouble() ?? 0.0,
                                calories:
                                    (i['calories'] as num?)?.toDouble() ?? 0.0,
                              ))
                          .toList() ??
                      [];

              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4,
                child: InkWell(
                  // Navigate to meal details screen
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealHomeScreen(
                          meal: Meal(
                            name: name,
                            calories: calories,
                            weight: weight,
                            nutrients: nutrients,
                            ingredients: ingredients,
                          ),
                          imageUrl: imageUrl,
                          isFavorite: true,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.fastfood,
                                size: 60, color: Colors.grey),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            "Calories: $calories kcal",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            "Khối lượng: $weight g",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editMealName(docId, name);
                          } else if (value == 'delete') {
                            _deleteFavoriteMeal(docId);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text("Chỉnh sửa"),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text("Xóa"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}