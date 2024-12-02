import 'package:app/information_screen/height_selection.dart';
import 'package:flutter/material.dart';

class AgeSelectionScreen extends StatefulWidget {
  final String selectedGender;

  const AgeSelectionScreen({Key? key, required this.selectedGender})
      : super(key: key);

  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int _selectedAge = 21;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Bạn bao nhiêu tuổi?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
                controller: FixedExtentScrollController(initialItem: _selectedAge),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedAge = index + 18;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Text(
                      "${index + 18}",
                      style: TextStyle(
                        fontSize: index + 18 == _selectedAge ? 36 : 28,
                        fontWeight: index + 18 == _selectedAge
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index + 18 == _selectedAge
                            ? Colors.black
                            : Colors.grey,
                      ),
                    );
                  },
                  childCount: 83,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HeightSelectionScreen(
                      selectedGender: widget.selectedGender,
                      selectedAge: _selectedAge,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Tiếp tục"),
            ),
          ),
        ],
      ),
    );
  }
}
