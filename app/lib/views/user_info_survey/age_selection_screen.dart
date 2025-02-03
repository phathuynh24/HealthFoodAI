import 'package:app/core/constants/firebase_constants.dart';
import 'package:app/views/user_info_survey/height_selection_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AgeSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const AgeSelectionScreen({Key? key, required this.surveyData}) : super(key: key);

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  late int _selectedAge;

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.surveyData[UserFields.age] ?? 21;
  }

  void _continueToNextScreen() {
    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.age] = _selectedAge;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeightSelectionScreen(surveyData: updatedSurveyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Chọn Độ Tuổi"),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Bạn bao nhiêu tuổi?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Chúng tôi chỉ sử dụng dữ liệu của bạn để cải thiện trải nghiệm và tính năng ước lượng calo.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Center(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.5,
                controller: FixedExtentScrollController(initialItem: _selectedAge - 10),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedAge = index + 10;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Text(
                      "${index + 10}",
                      style: TextStyle(
                        fontSize: index + 10 == _selectedAge ? 36 : 28,
                        fontWeight: index + 10 == _selectedAge
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index + 10 == _selectedAge
                            ? Colors.black
                            : Colors.grey,
                      ),
                    );
                  },
                  childCount: 91, // From 10 to 100 (100 - 10 + 1 = 91)
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _continueToNextScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Tiếp tục", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
