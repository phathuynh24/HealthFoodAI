import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/user_info_survey/activity_selection_screen.dart';
import 'package:app/views/user_info_survey/goal_weight_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CurrentWeightScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const CurrentWeightScreen({Key? key, required this.surveyData})
      : super(key: key);

  @override
  State<CurrentWeightScreen> createState() => _CurrentWeightScreenState();
}

class _CurrentWeightScreenState extends State<CurrentWeightScreen> {
  late int integerPart;
  late int decimalPart;

  @override
  void initState() {
    super.initState();
    double weight = widget.surveyData[UserFields.weight] ?? 70.0;
    integerPart = weight.floor().clamp(20, 200);
    decimalPart = ((weight - integerPart) * 10).toInt().clamp(0, 9);
  }

  void _continueToNextScreen() {
    double weight = integerPart + (decimalPart / 10);
    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.weight] = weight;

    if (widget.surveyData[UserFields.goal] == "Duy trì cân nặng") {
      updatedSurveyData[UserFields.targetWeight] = weight;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivitySelectionScreen(surveyData: updatedSurveyData),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalWeightScreen(surveyData: updatedSurveyData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Cân nặng hiện tại"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Cân nặng hiện tại của bạn?",
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
                          integerPart = 20 + index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          String displayWeight = (index + 20).toString();
                          return Center(
                            child: Text(
                              displayWeight,
                              style: TextStyle(
                                  fontSize: index + 20 == integerPart ? 68 : 54,
                                  fontWeight: index + 20 == integerPart
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: index + 20 == integerPart
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                          );
                        },
                        childCount: 181, // Range from 20 to 200
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
                        childCount: 10, // Range from 0 to 9 (0.0 to 0.9 kg)
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  " kg",
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                ),
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
