import 'package:app/core/calorie_calculator/calorie_calculator.dart';
import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/user_info_survey/activity_selection_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeightChangeRateScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;
  final bool isSetting;

  const WeightChangeRateScreen({
    Key? key,
    required this.surveyData,
    this.isSetting = false,
  }) : super(key: key);

  @override
  State<WeightChangeRateScreen> createState() => _WeightChangeRateScreenState();
}

class _WeightChangeRateScreenState extends State<WeightChangeRateScreen> {
  double? selectedRate;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final bool isLosingWeight = widget.surveyData['goal'] == 'Giảm cân';
    final List<double> weightChangeOptions =
        isLosingWeight ? [0.5, 1.0, 1.5, 2.0] : [0.5, 1.0];

    return Stack(
      children: [
        Scaffold(
          appBar: const CustomAppBar(title: 'Thay đổi cân nặng'),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Mục tiêu thay đổi cân nặng mỗi tuần?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ...weightChangeOptions
                    .map((rate) => _buildOption(rate, isLosingWeight))
                    .toList(),
                const Spacer(),
                ElevatedButton(
                  onPressed: selectedRate != null
                      ? () => _continueToNextScreen(
                          context, widget.surveyData, widget.isSetting)
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Tiếp tục",
                    style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _buildOption(double rate, bool isLosingWeight) {
    final String label =
        isLosingWeight ? 'Giảm $rate kg mỗi tuần' : 'Tăng $rate kg mỗi tuần';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRate = rate;
          widget.surveyData['weightChangeRate'] = rate;
        });

        if (isLosingWeight && (rate == 1.5 || rate == 2.0)) {
          _showWarningDialog();
        }
      },
      child: Container(
        width: double.infinity * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selectedRate == rate
              ? Colors.green.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedRate == rate ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
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

      // Cập nhật dữ liệu người dùng chính
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        'targetWeight': surveyData['targetWeight'],
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
        surveyHistory[existingIndex]['calories'] = roundedCalories;
        surveyHistory[existingIndex]['timestamp'] = currentTimestamp;
      } else {
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

  void _continueToNextScreen(BuildContext context,
      Map<String, dynamic> surveyData, bool isSetting) async {
    Map<String, dynamic> updatedSurveyData = Map.from(surveyData);

    if (isSetting) {
      await saveSurveyData(context, updatedSurveyData);
      if (context.mounted) {
        Navigator.of(context).popUntil(
            (route) => route.settings.name == 'WeightChangeSelectionScreen');
        Navigator.pop(context, updatedSurveyData);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ActivitySelectionScreen(surveyData: updatedSurveyData),
        ),
      );
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cảnh báo'),
        content: const Text(
          'Việc giảm cân nhanh (1.5 kg hoặc 2 kg mỗi tuần) có thể gây hại cho sức khỏe. Hãy tham khảo ý kiến chuyên gia trước khi thực hiện.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}
