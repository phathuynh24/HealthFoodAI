import 'package:app/views/user_info_survey/calories_plan_screen.dart';
import 'package:flutter/material.dart';

class ActivitySelectionScreen extends StatefulWidget {
  final String selectedGender;
  final String selectedWeightChange;
  final int selectedAge;
  final int selectedHeight;
  final double selectedCurrentWeight;
  final double selectedGoalWeight;
  const ActivitySelectionScreen({
    Key? key,
    required this.selectedWeightChange,
    required this.selectedGender,
    required this.selectedAge,
    required this.selectedHeight,
    required this.selectedCurrentWeight,
    required this.selectedGoalWeight,
  }) : super(key: key);
  @override
  _ActivitySelectionScreenState createState() =>
      _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<ActivitySelectionScreen> {
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
              "Mức độ hoạt động của bạn?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Danh sách các mức độ vận động
            buildActivityOption("Không vận động nhiều",
                "Chủ yếu ngồi, giống công việc văn phòng hoặc lập trình viên."),
            buildActivityOption("Hơi vận động",
                "Di chuyển nhẹ nhàng hàng ngày, thường xuyên đứng, giống như nhân viên bán lẻ hoặc y tá."),
            buildActivityOption("Vận động vừa phải",
                "Hoạt động bình thường trong ngày, đi bộ nhiều hoặc làm việc nhà thường xuyên."),
            buildActivityOption("Vận động nhiều",
                "Hoạt động liên tục cả ngày, giống nhân viên kho hoặc giao hàng."),
            buildActivityOption("Vận động rất nhiều",
                "Thường xuyên làm việc thể lực nặng, giống như công nhân xây dựng."),
            Spacer(),

            // Nút Tiếp tục
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
                  "Tiếp tục",
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
