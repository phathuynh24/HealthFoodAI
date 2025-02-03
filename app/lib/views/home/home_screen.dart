import 'package:app/product_scan.dart';
import 'package:app/widgets/water_tracker_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day)
              ? "Today"
              : DateFormat('dd-MM-yyyy').format(selectedDate),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.subtract(Duration(days: 1));
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.green),
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.add(Duration(days: 1));
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('logged_meals')
            .where('loggedAt',
                isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final totalCalories = docs.fold<int>(
            0,
            (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              final calories = (data['calories'] ?? 0) as num;
              return sum + calories.toInt();
            },
          );

          return Column(
            children: [
              _buildCalorieSummary(totalCalories),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildMealEntry("My Daily Dietary Report", Icons.fastfood),
                    _buildMealTypeSection('Buổi sáng', Icons.breakfast_dining),
                    _buildMealTypeSection('Buổi trưa', Icons.lunch_dining),
                    _buildMealTypeSection('Buổi tối', Icons.dinner_dining),
                    _buildMealTypeSection('Ăn vặt', Icons.fastfood),
                    Divider(),
                    _buildExerciseEntry(
                        "Exercise", Icons.directions_run, "0 Cal"),
                    _buildExerciseEntry(
                        "Daily steps", Icons.directions_walk, "5000 steps"),
                    WaterTrackerWidget()
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Diary"),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add, color: Colors.green), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: "Recipes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Mine"),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductScanScreen(),
            ),
          );
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildCalorieSummary(int totalCalories) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('logged_meals')
            .where('loggedAt',
                isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          // double totalCalories = 0;
          double totalCarbs = 0;
          double totalProtein = 0;
          double totalFat = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final nutrients = data['nutrients'] as List<dynamic>? ?? [];

            // totalCalories += (data['calories'] ?? 0) as int;
            //   totalCarbs += (data['carbs'] ?? 0);
            //   totalProtein += (data['protein'] ?? 0);
            //   totalFat += (data['fat'] ?? 0);
            // }

            for (var nutrient in nutrients) {
              final nutrientData = nutrient as Map<String, dynamic>;
              final name = nutrientData['name'];
              final amount = nutrientData['amount'] ?? 0;

              if (name == "Total Carbohydrate") {
                totalCarbs += amount;
              } else if (name == "Protein") {
                totalProtein += amount;
              } else if (name == "Total Fat") {
                totalFat += amount;
              }
            }
          }
          totalCarbs = double.parse(totalCarbs.toStringAsFixed(1));
          totalProtein = double.parse(totalProtein.toStringAsFixed(1));
          totalFat = double.parse(totalFat.toStringAsFixed(1));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Calories",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("Remaining = Goal - Food + Exercise"),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hiển thị hình tròn Calorie
                        _buildCircularCalorieDisplay(totalCalories),
                        // Thông tin chi tiết Calorie
                        _buildCalorieDetails(),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutrientInfo("Carbs", "$totalCarbs"),
                        _buildNutrientInfo("Protein", "$totalProtein"),
                        _buildNutrientInfo("Fat", "$totalFat"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildCircularCalorieDisplay(int totalCalories) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: totalCalories / 2502,
                strokeWidth: 8,
                color: Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
              Center(
                child: Text(
                  totalCalories.toString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text("Remaining"),
      ],
    );
  }

  Widget _buildCalorieDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.orange),
            SizedBox(width: 4),
            Text("Base Goal: 2502"),
          ],
        ),
        Row(
          children: [
            Icon(Icons.restaurant, color: Colors.blue),
            SizedBox(width: 4),
            Text("Food: 0"),
          ],
        ),
        Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red),
            SizedBox(width: 4),
            Text("Exercise: 0"),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientInfo(String nutrient, String value) {
    return Column(
      children: [
        Text(nutrient, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  Widget _buildExerciseEntry(String title, IconData icon, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontSize: 18)),
      trailing:
          Text(value, style: TextStyle(fontSize: 16, color: Colors.green)),
    );
  }

  Widget _buildMealEntry(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildMealTypeSection(String mealType, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.orange),
          title: Text(mealType, style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.add, color: Colors.green),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('logged_meals')
              .where('type', isEqualTo: mealType)
              .where('loggedAt',
                  isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final meals = snapshot.data?.docs ?? [];

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index].data() as Map<String, dynamic>;
                return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                        leading: meal['imageUrl'] != null &&
                                meal['imageUrl'].toString().startsWith('http')
                            ? Image.network(
                                meal['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.fastfood),
                        title: Text(meal['originalName'] ?? ''),
                        subtitle: Text(
                          meal['loggedAt'] ?? '',
                        )));
              },
            );
          },
        )
      ],
    );
  }
}
