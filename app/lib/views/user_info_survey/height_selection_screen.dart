import 'package:app/core/constants/firebase_constants.dart';
import 'package:app/views/user_info_survey/weight_change_selection.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class HeightSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const HeightSelectionScreen({Key? key, required this.surveyData}) : super(key: key);

  @override
  State<HeightSelectionScreen> createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  late int _selectedHeight;

  @override
  void initState() {
    super.initState();
    _selectedHeight = widget.surveyData[UserFields.height] ?? 170;
  }

  void _continueToNextScreen() {
    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.height] = _selectedHeight;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeightChangeSelectionScreen(surveyData: updatedSurveyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Chọn Chiều Cao"),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Chiều cao của bạn là bao nhiêu?",
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
                diameterRatio: 1.5,
                controller: FixedExtentScrollController(initialItem: _selectedHeight - 100),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedHeight = index + 100;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Text(
                      "${index + 100} cm",
                      style: TextStyle(
                        fontSize: index + 100 == _selectedHeight ? 36 : 28,
                        color: index + 100 == _selectedHeight ? Colors.black : Colors.grey,
                      ),
                    );
                  },
                  childCount: 151, // Height range from 100 to 251 cm
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
