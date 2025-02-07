import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/user_info_survey/weight_change_rate_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class GoalWeightScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;
  final bool isSetting;

  const GoalWeightScreen(
      {Key? key, required this.surveyData, this.isSetting = false})
      : super(key: key);

  @override
  State<GoalWeightScreen> createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  late int integerPart;
  late int decimalPart;
  late int minWeight;
  late int maxWeight;

  @override
  void initState() {
    super.initState();
    double currentWeight = widget.surveyData[UserFields.weight] ?? 70.0;

    if (widget.surveyData[UserFields.goal] == "Tăng cân") {
      minWeight = currentWeight.floor();
      maxWeight = 200;
    } else if (widget.surveyData[UserFields.goal] == "Giảm cân") {
      minWeight = 20;
      maxWeight = currentWeight.floor();
    } else {
      minWeight = 20;
      maxWeight = 200;
    }

    integerPart = minWeight;
    decimalPart = 0;
  }

  void _continueToNextScreen() {
    double targetWeight = integerPart + (decimalPart / 10);
    double currentWeight = widget.surveyData[UserFields.weight] ?? 70.0;
    String goal = widget.surveyData[UserFields.goal] ?? "Duy trì cân nặng";

    // Kiểm tra điều kiện hợp lệ
    if ((goal == "Tăng cân" && targetWeight <= currentWeight) ||
        (goal == "Giảm cân" && targetWeight >= currentWeight)) {
      _showErrorDialog(goal);
      return; // Không cho phép tiếp tục nếu không hợp lệ
    }

    // Nếu hợp lệ, tiếp tục lưu dữ liệu
    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.targetWeight] = targetWeight;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeightChangeRateScreen(
          surveyData: updatedSurveyData,
          isSetting: widget.isSetting,
        ),
      ),
    );
  }

  // Hiển thị cảnh báo lỗi
  void _showErrorDialog(String goal) {
    String message = goal == "Tăng cân"
        ? "Cân nặng mục tiêu phải lớn hơn cân nặng hiện tại để đạt mục tiêu tăng cân."
        : "Cân nặng mục tiêu phải nhỏ hơn cân nặng hiện tại để đạt mục tiêu giảm cân.";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cảnh báo",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đã hiểu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Cân nặng mục tiêu"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Cân nặng mục tiêu của bạn là?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Ước lượng hiện tại, bạn có thể chỉnh sửa sau.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 210,
                    width: 140,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 90,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          integerPart = minWeight + index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              '${minWeight + index}',
                              style: TextStyle(
                                  fontSize: minWeight + index == integerPart
                                      ? 68
                                      : 54,
                                  fontWeight: minWeight + index == integerPart
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: minWeight + index == integerPart
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                          );
                        },
                        childCount: (maxWeight - minWeight) + 1,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                ".",
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    width: 60,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 90,
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
                        childCount:
                            10, // Decimal part from 0 to 9 (0.0 to 0.9 kg)
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
              onPressed: _continueToNextScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Tiếp tục",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
