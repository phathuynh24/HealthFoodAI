import 'package:app/calories_plan_screen.dart';
import 'package:flutter/material.dart';

class ActivityLevelScreen extends StatefulWidget {
  final String selectedGender;
  final String selectedWeightChange;
  final int selectedAge;
  final int selectedHeight;
  final double selectedCurrentWeight;
  final double selectedGoalWeight;
  const ActivityLevelScreen({
    Key? key,
    required this.selectedWeightChange,
    required this.selectedGender,
    required this.selectedAge,
    required this.selectedHeight,
    required this.selectedCurrentWeight,
    required this.selectedGoalWeight,
  }) : super(key: key);
  @override
  _ActivityLevelScreenState createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String selectedActivityLevel = ""; // Lưu trữ mức độ vận động được chọn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.green[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Tiêu đề
            Text(
              "What's your activity level?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Danh sách các mức độ vận động
            buildActivityOption("Not Active",
                "Mostly sedentary, akin to an office worker or computer programmer."),
            buildActivityOption("Somewhat Active",
                "Light daily movement, frequently on feet, similar to a retail worker or nurse."),
            buildActivityOption("Moderately Active",
                "Normal work of the day, walk alot or had to do lot of house chore."),
            buildActivityOption("Highly Active",
                "Active most of the day, comparable to a warehouse worker or courier."),
            buildActivityOption("Extremely Active",
                "Mostly involved in intense physical labor, like a construction worker."),
            Spacer(),

            // Nút Next
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedActivityLevel.isEmpty
                    ? null
                    : () {
                        // Chuyển sang màn hình tính toán calories
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaloriePlanScreen(
                              activityLevel: selectedActivityLevel,
                              gender: widget.selectedGender,
                              age: widget.selectedAge,
                              height: widget.selectedHeight,
                              targetWeight: widget.selectedGoalWeight,
                              weight: widget.selectedCurrentWeight,
                              goal: widget.selectedWeightChange,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedActivityLevel.isEmpty
                      ? Colors.grey
                      : Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị từng mức độ vận động
  Widget buildActivityOption(String title, String description) {
    final isSelected = selectedActivityLevel == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedActivityLevel = title;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.green : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
