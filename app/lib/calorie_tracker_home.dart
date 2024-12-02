import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/widgets/water_tracker_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalorieTrackerHome extends StatefulWidget {
  @override
  _CalorieTrackerHomeState createState() => _CalorieTrackerHomeState();
}

class _CalorieTrackerHomeState extends State<CalorieTrackerHome> {
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
              selectedDate =
                  selectedDate.subtract(Duration(days: 1)); // Ngày trước đó
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.green),
            onPressed: () {
              setState(() {
                selectedDate =
                    selectedDate.add(Duration(days: 1)); // Ngày tiếp theo
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
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          // Tính tổng calories
          int totalCalories = snapshot.data!.docs.fold(0, (sum, doc) {
            var data = doc.data() as Map<String, dynamic>;
            return sum +
                ((data['calories']?.toInt() ?? 0)
                    as int); // Đảm bảo `calories` có giá trị mặc định nếu null
          });

          // var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.brown.shade700,
                child: Row(
                  children: [
                    Icon(Icons.mail, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your free 7-day Premium hasn't been claimed yet. Tap to claim",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Calorie Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Calories",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text("Remaining = Goal - Food + Exercise"),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Circular calorie display
                            Column(
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
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text("Remaining"),
                              ],
                            ),

                            // Calorie details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.emoji_events,
                                        color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text("Base Goal: 2502"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.restaurant, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text("Food: 524"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.local_fire_department,
                                        color: Colors.red),
                                    SizedBox(width: 4),
                                    Text("Exercise: 0"),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Nutrient summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNutrientInfo("Carbs", "50/218g"),
                            _buildNutrientInfo("Protein", "35/250g"),
                            _buildNutrientInfo("Fat", "15/69g"),
                            _buildNutrientInfo("Fiber", "5/38g"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Meal Entries
              Expanded(
                child: ListView(
                  children: [
                    _buildMealEntry("My Daily Dietary Report", Icons.fastfood),
                    _buildMealEntry("Breakfast", Icons.breakfast_dining),
                    _buildMealEntry("Lunch", Icons.lunch_dining),
                    _buildMealEntry("Dinner", Icons.dinner_dining),
                    Divider(), // Tạo đường kẻ phân cách
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

  Widget _buildMealEntry(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(fontSize: 18)),
      trailing: Icon(Icons.add, color: Colors.green),
      onTap: () {},
    );
  }

  Widget _buildExerciseEntry(String title, IconData icon, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontSize: 18)),
      trailing:
          Text(value, style: TextStyle(fontSize: 16, color: Colors.green)),
      onTap: () {
        // Hành động khi nhấn
      },
    );
  }
}