import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/main_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CalorieSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const CalorieSummaryScreen({super.key, required this.surveyData});

  @override
  State<CalorieSummaryScreen> createState() => _CalorieSummaryScreenState();
}

class _CalorieSummaryScreenState extends State<CalorieSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double bmr = calculateBMR(
      widget.surveyData[UserFields.gender],
      widget.surveyData[UserFields.weight],
      widget.surveyData[UserFields.height],
      widget.surveyData[UserFields.age],
    );

    final double tdee =
        calculateTDEE(bmr, widget.surveyData[UserFields.activityLevel]);
    final double adjustedCalories = adjustCalories(
        tdee,
        widget.surveyData[UserFields.goal],
        widget.surveyData[UserFields.weightChangeRate]);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.green[50],
          appBar: const CustomAppBar(title: "Kết Quả Tính Toán"),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Chỉ số calo hàng ngày của bạn",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Dựa trên thông tin bạn đã cung cấp, đây là mức calo đề xuất để đạt mục tiêu của bạn.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // Total Calories
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            "Tổng lượng calo/ngày",
                            style: TextStyle(
                                fontSize: 16, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                      Text(
                        "${adjustedCalories.toStringAsFixed(0)} Cal",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Time to Re-survey
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Bạn có thể làm lại khảo sát lại ở mục 'Cài đặt' để cập nhật mục tiêu và thể trạng của mình.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),

                // Info Summary
                _buildSummaryItem(
                    "Giới tính",
                    widget.surveyData[UserFields.gender] == "Male"
                        ? "Nam"
                        : "Nữ"),
                _buildSummaryItem(
                    "Tuổi", widget.surveyData[UserFields.age].toString()),
                _buildSummaryItem(
                    "Chiều cao", "${widget.surveyData[UserFields.height]} cm"),
                _buildSummaryItem("Cân nặng hiện tại",
                    "${widget.surveyData[UserFields.weight]} kg"),
                _buildSummaryItem("Cân nặng mục tiêu",
                    "${widget.surveyData[UserFields.targetWeight]} kg"),
                _buildSummaryItem("Mức độ vận động",
                    widget.surveyData[UserFields.activityLevel]),
                _buildSummaryItem(
                    "Mục tiêu", widget.surveyData[UserFields.goal]),

                if (widget.surveyData[UserFields.weightChangeRate] != null &&
                    widget.surveyData[UserFields.goal] != "Duy trì cân nặng")
                  _buildSummaryItem(
                    "Mức độ ${widget.surveyData[UserFields.goal] == "Giảm cân" ? "giảm" : "tăng"} cân/tuần",
                    "${widget.surveyData[UserFields.weightChangeRate]} kg/tuần",
                  ),

                const Spacer(),

                // Save & Finish Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveSurveyData(context, adjustedCalories),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Lưu và Kết Thúc",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  // Save Survey Data
  Future<void> _saveSurveyData(
      BuildContext context, double adjustedCalories) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Timestamp currentTimestamp = Timestamp.now();
      int roundedCalories = adjustedCalories.round();

      // Update main user data
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        UserFields.gender: widget.surveyData[UserFields.gender],
        UserFields.age: widget.surveyData[UserFields.age],
        UserFields.height: widget.surveyData[UserFields.height],
        UserFields.weight: widget.surveyData[UserFields.weight],
        UserFields.targetWeight: widget.surveyData[UserFields.targetWeight],
        UserFields.activityLevel: widget.surveyData[UserFields.activityLevel],
        UserFields.goal: widget.surveyData[UserFields.goal],
        UserFields.calories: roundedCalories,
        UserFields.updatedAt: currentTimestamp,
        UserFields.isFirstLogin: false,
        UserFields.weightChangeRate: widget.surveyData[UserFields.weightChangeRate],
      });

      // Save survey history
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        UserFields.surveyHistory: FieldValue.arrayUnion([
          {
            UserFields.timestamp: currentTimestamp,
            ...widget.surveyData,
            UserFields.calories: adjustedCalories,
          }
        ])
      });

      if (context.mounted) {
        CustomSnackbar.show(context, "Lưu thông tin thành công!",
            isSuccess: true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, "Lỗi: ${e.toString()}", isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Calculate BMR
  double calculateBMR(String gender, double weight, int height, int age) {
    return gender == "Male"
        ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
  }

  // Calculate TDEE
  double calculateTDEE(double bmr, String activityLevel) {
    const activityMultipliers = {
      "Không vận động nhiều": 1.2,
      "Hơi vận động": 1.375,
      "Vận động vừa phải": 1.55,
      "Vận động nhiều": 1.725,
      "Vận động rất nhiều": 1.9
    };
    return bmr * (activityMultipliers[activityLevel] ?? 1.2);
  }

  double adjustCalories(double tdee, String goal, double? weightChangeRate) {
    const caloriesPerKg = 7700; // 1 kg ≈ 7700 calories

    // Tính lượng calo cần thay đổi mỗi ngày
    double dailyCalorieAdjustment = 0;
    if (weightChangeRate != null && goal != "Duy trì cân nặng") {
      dailyCalorieAdjustment = (weightChangeRate * caloriesPerKg) / 7;
    }

    // Điều chỉnh calo dựa vào mục tiêu
    if (goal == "Giảm cân") {
      return tdee - dailyCalorieAdjustment;
    } else if (goal == "Tăng cân") {
      return tdee + dailyCalorieAdjustment;
    } else {
      return tdee; // Duy trì cân nặng
    }
  }

  Widget _buildSummaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
