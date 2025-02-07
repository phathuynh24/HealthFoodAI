import 'package:app/core/calorie_calculator/calorie_calculator.dart';
import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/user_info_survey/current_weight_screen.dart';
import 'package:app/views/user_info_survey/goal_weight_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeightChangeSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;
  final bool isSetting;

  const WeightChangeSelectionScreen({
    Key? key,
    required this.surveyData,
    this.isSetting = false,
  }) : super(key: key);

  @override
  State<WeightChangeSelectionScreen> createState() =>
      _WeightChangeSelectionScreenState();
}

class _WeightChangeSelectionScreenState
    extends State<WeightChangeSelectionScreen> {
  late String selectedGoal;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedGoal = widget.surveyData[UserFields.goal] ?? "";
  }

  Future<void> saveSurveyData(
      BuildContext context, Map<String, dynamic> surveyData) async {
    try {
      setState(() {
        isSaving = true;
      });

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final currentTimestamp = Timestamp.now();

      // Tính toán lượng calo
      final double bmr = CalorieCalculator.calculateBMR(
        surveyData['gender'],
        surveyData['weight'],
        surveyData['height'],
        surveyData['age'],
      );

      final double tdee = CalorieCalculator.calculateTDEE(
        bmr,
        surveyData['activityLevel'],
      );

      final double adjustedCalories = CalorieCalculator.adjustCalories(
        tdee,
        surveyData['goal'],
        surveyData['weightChangeRate'],
      );

      int roundedCalories = adjustedCalories.round();

      // Cập nhật dữ liệu chính của người dùng
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        'targetWeight': surveyData['weight'],
        'goal': surveyData['goal'],
        'calories': roundedCalories,
        'updatedAt': currentTimestamp,
        'weightChangeRate': surveyData['weightChangeRate'],
      });

      DateTime now = DateTime.now();
      String dateKey = DateFormat('dd-MM-yyyy').format(now);

      // Lấy dữ liệu surveyHistory hiện tại
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      List<dynamic> surveyHistory = userDoc['surveyHistory'] ?? [];

      // Kiểm tra xem đã có dữ liệu cho ngày hiện tại chưa
      int existingIndex = surveyHistory.indexWhere(
        (entry) => entry['date'] == dateKey,
      );

      if (existingIndex != -1) {
        // Nếu đã có, cập nhật lại calories và timestamp
        surveyHistory[existingIndex]['calories'] = roundedCalories;
        surveyHistory[existingIndex]['timestamp'] = currentTimestamp;
      } else {
        // Nếu chưa có, thêm mới
        surveyHistory.add({
          'date': dateKey,
          'calories': roundedCalories,
          'timestamp': currentTimestamp,
        });
      }

      // Lưu lại dữ liệu lịch sử khảo sát đã cập nhật
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'surveyHistory': surveyHistory,
      });

      if (context.mounted) {
        CustomSnackbar.show(context, "Lưu thông tin thành công!",
            isSuccess: true);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, "Lỗi: ${e.toString()}", isSuccess: false);
      }
    } finally {
      if (context.mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _handleProcessSetting(Map<String, dynamic> updatedSurveyData) async {
    if (widget.isSetting) {
      if (updatedSurveyData[UserFields.goal] == "Duy trì cân nặng") {
        await saveSurveyData(context, updatedSurveyData);
        if (mounted) {
          Navigator.pop(context, updatedSurveyData);
        }
      } else {
        final updatedData = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalWeightScreen(
                surveyData: updatedSurveyData, isSetting: widget.isSetting),
          ),
        );

        if (updatedData != null && mounted) {
          Navigator.pop(context, updatedData);
        }
      }
    }
  }

  void _continueToNextScreen() {
    if (selectedGoal.isEmpty) {
      CustomSnackbar.show(context, "Vui lòng chọn mục tiêu!", isSuccess: false);
      return;
    }

    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.goal] = selectedGoal;

    if (widget.isSetting) {
      _handleProcessSetting(updatedSurveyData);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CurrentWeightScreen(surveyData: updatedSurveyData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
        ),
        // Loading Indicator
        if (isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
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
