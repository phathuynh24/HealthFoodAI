import 'package:app/weight_change_selection.dart';
import 'package:flutter/material.dart';

class HeightSelectionScreen extends StatefulWidget {
  final String selectedGender;
  final int selectedAge;

  const HeightSelectionScreen({
    Key? key,
    required this.selectedGender,
    required this.selectedAge,
  }) : super(key: key);

  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int _selectedHeight = 170;

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
          const SizedBox(height: 20),
          const Text(
            "What's your height?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50,
                diameterRatio: 1.5,
                controller: FixedExtentScrollController(initialItem: 50), //set the wheel to the midle
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
                        color: index + 100 == _selectedHeight
                            ? Colors.black
                            : Colors.grey,
                      ),
                    );
                  },
                  childCount: 151, // Chiều cao từ 100 đến 250
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
                    builder: (context) => WeightChangeSelectionScreen(
                      selectedGender: widget.selectedGender,
                      selectedAge: widget.selectedAge,
                      selectedHeight: _selectedHeight,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Next"),
            ),
          ),
        ],
      ),
    );
  }
}