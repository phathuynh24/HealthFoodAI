import 'package:app/activity_level_screen.dart';
import 'package:flutter/material.dart';

class GoalWeightScreen extends StatefulWidget {
  final String selectedGender;
  final String selectedWeightChange;
  final int selectedAge;
  final int selectedHeight;
  final double selectedCurrentWeight;
  const GoalWeightScreen({
    Key? key,
    required this.selectedWeightChange,
    required this.selectedGender,
    required this.selectedAge,
    required this.selectedHeight,
    required this.selectedCurrentWeight,
  }) : super(key: key);
  @override
  _GoalWeightScreenState createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  int integerPart = 70;
  int decimalPart = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "What's your goal weight?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Estimate now, adjust later is fine.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 200,
                    width: 100,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 80,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          integerPart = 30 + index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              '${30 + index}',
                              style: TextStyle(
                                  fontSize: index + 30 == integerPart ? 68 : 54,
                                  fontWeight: index + 30 == integerPart
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: index + 30 == integerPart
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                          );
                        },
                        childCount: 71, // Giới hạn từ 30kg đến 100kg
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                ".",
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
              ),
              // Bộ chọn phần thập phân
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    width: 60,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 80,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          decimalPart = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              '$index',
                              style: TextStyle(
                                  fontSize: index == decimalPart ? 68 : 54,
                                  fontWeight: index == decimalPart
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: index == decimalPart
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                          );
                        },
                        childCount: 10, // Phần thập phân từ 0 đến 9
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                " kg",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                double weight = integerPart + (decimalPart / 10);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityLevelScreen(
                      selectedGender: widget.selectedGender,
                      selectedAge: widget.selectedAge,
                      selectedHeight: widget.selectedHeight,
                      selectedCurrentWeight: widget.selectedCurrentWeight,
                      selectedGoalWeight: weight,
                      selectedWeightChange: widget.selectedWeightChange,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Next"),
            ),
          ),
        ],
      ),
    );
  }
}
