import 'package:app/current_weight_screen.dart';
import 'package:flutter/material.dart';

class WeightChangeSelectionScreen extends StatefulWidget {
  final String selectedGender;
  final int selectedAge;
  final int selectedHeight;
  const WeightChangeSelectionScreen({
    Key? key,
    required this.selectedGender,
    required this.selectedAge,
    required this.selectedHeight,
  }) : super(key: key);
  @override
  _WeightChangeSelectionScreenState createState() =>
      _WeightChangeSelectionScreenState();
}

class _WeightChangeSelectionScreenState
    extends State<WeightChangeSelectionScreen> {
  String selectedGoal = "Tăng cân"; // Mục tiêu mặc định

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            const Text(
              "Mục tiêu của bạn là gì?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Mô tả nhỏ
            const Text(
              "Chúng tôi chỉ sử dụng dữ liệu của bạn để cải thiện trải nghiệm và tính năng ước lượng calo.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Các lựa chọn
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildGoalOption("Giảm cân"),
                  buildGoalOption("Duy trì cân nặng"),
                  buildGoalOption("Tăng cân"),
                ],
              ),
            ),

            // Nút Tiếp tục
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CurrentWeightScreen(
                        selectedGender: widget.selectedGender,
                        selectedAge: widget.selectedAge,
                        selectedHeight: widget.selectedHeight,
                        selectedWeightChange: selectedGoal,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
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

  // Widget cho từng lựa chọn
  Widget buildGoalOption(String goal) {
    bool isSelected = selectedGoal == goal;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal; // Cập nhật mục tiêu đã chọn
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.grey[200],
          border: Border.all(
              color: isSelected ? Colors.greenAccent : Colors.grey[300]!,
              width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          goal,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.green : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
