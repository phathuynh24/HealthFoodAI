import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/user_info_survey/current_weight_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class WeightChangeSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const WeightChangeSelectionScreen({
    Key? key,
    required this.surveyData,
  }) : super(key: key);

  @override
  State<WeightChangeSelectionScreen> createState() =>
      _WeightChangeSelectionScreenState();
}

class _WeightChangeSelectionScreenState
    extends State<WeightChangeSelectionScreen> {
  late String selectedGoal;

  @override
  void initState() {
    super.initState();
    selectedGoal = widget.surveyData[UserFields.goal] ?? "";
  }

  void _continueToNextScreen() {
    if (selectedGoal.isEmpty) {
      CustomSnackbar.show(context, "Vui lòng chọn mục tiêu!", isSuccess: false);
      return;
    }

    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.goal] = selectedGoal;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CurrentWeightScreen(surveyData: updatedSurveyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Chọn Mục Tiêu"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Mục tiêu của bạn là gì?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Chúng tôi chỉ sử dụng dữ liệu của bạn để cải thiện trải nghiệm và tính năng ước lượng calo.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continueToNextScreen,
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

  Widget buildGoalOption(String goal) {
    bool isSelected = selectedGoal == goal;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.grey[200],
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
