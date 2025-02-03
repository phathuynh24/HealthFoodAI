import 'package:app/core/constants/firebase_constants.dart';
import 'package:app/views/user_info_survey/age_selection_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class GenderSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;
  const GenderSelectionScreen({super.key, required this.surveyData});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String _selectedGender = "";

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.surveyData[UserFields.gender] ?? "";
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _continueToNextScreen() {
    if (_selectedGender.isEmpty) {
      CustomSnackbar.show(context, "Vui lòng chọn giới tính!", isSuccess: false);
      return;
    }

    Map<String, dynamic> updatedSurveyData = Map.from(widget.surveyData);
    updatedSurveyData[UserFields.gender] = _selectedGender;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgeSelectionScreen(surveyData: updatedSurveyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Chọn Giới Tính"),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Giới tính của bạn là gì?",
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GenderOption(
                    gender: "Male",
                    label: "Nam",
                    icon: Icons.male,
                    selectedGender: _selectedGender,
                    onSelect: _selectGender,
                  ),
                  const SizedBox(height: 20),
                  GenderOption(
                    gender: "Female",
                    label: "Nữ",
                    icon: Icons.female,
                    selectedGender: _selectedGender,
                    onSelect: _selectGender,
                  ),
                ],
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

class GenderOption extends StatelessWidget {
  final String gender;
  final String label;
  final IconData icon;
  final String selectedGender;
  final Function(String) onSelect;

  const GenderOption({
    super.key,
    required this.gender,
    required this.label,
    required this.icon,
    required this.selectedGender,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => onSelect(gender),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.greenAccent : Colors.grey.shade200,
              width: 2),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.green[50] : Colors.grey[200],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: gender == "Male" ? Colors.blue : Colors.pink),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.green : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
