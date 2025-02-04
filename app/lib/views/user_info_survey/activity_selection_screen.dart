import 'package:app/core/constants/firebase_constants.dart';
import 'package:app/views/user_info_survey/calorie_summary_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ActivitySelectionScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const ActivitySelectionScreen({Key? key, required this.surveyData})
      : super(key: key);

  @override
  State<ActivitySelectionScreen> createState() =>
      _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<ActivitySelectionScreen> {
  String selectedActivityLevel = "";

  @override
  void initState() {
    super.initState();
    selectedActivityLevel =
        widget.surveyData[UserFields.activityLevel] ?? "";
  }

  void _continueToNextScreen() {
    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.activityLevel] = selectedActivityLevel;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalorieSummaryScreen(surveyData: updatedSurveyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Chọn Mức Độ Hoạt Động"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Mức độ hoạt động của bạn?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Chúng tôi chỉ sử dụng thông tin này để cá nhân hóa lượng calo phù hợp.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                buildActivityOption("Không vận động nhiều",
                    "Chủ yếu ngồi, ít hoạt động. Ví dụ: công việc văn phòng."),
                buildActivityOption("Hơi vận động",
                    "Di chuyển nhẹ nhàng hàng ngày, đứng thường xuyên. Ví dụ: nhân viên bán lẻ."),
                buildActivityOption("Vận động vừa phải",
                    "Hoạt động thường xuyên, đi bộ nhiều hoặc làm việc nhà."),
                buildActivityOption("Vận động nhiều",
                    "Hoạt động liên tục cả ngày. Ví dụ: nhân viên kho, giao hàng."),
                buildActivityOption("Vận động rất nhiều",
                    "Thường xuyên làm việc thể lực nặng. Ví dụ: công nhân xây dựng."),
              ],
            ),
        
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedActivityLevel.isEmpty ? null : _continueToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedActivityLevel.isEmpty ? Colors.grey : Colors.green,
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
      ),
    );
  }

  Widget buildActivityOption(String title, String description) {
    final bool isSelected = selectedActivityLevel == title;
    return GestureDetector(
      onTap: () => setState(() => selectedActivityLevel = title),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
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
            const SizedBox(height: 4),
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
