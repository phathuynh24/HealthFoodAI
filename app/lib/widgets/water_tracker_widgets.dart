import 'package:flutter/material.dart';

class WaterTrackerWidget extends StatefulWidget {
  @override
  _WaterTrackerWidgetState createState() => _WaterTrackerWidgetState();
}

class _WaterTrackerWidgetState extends State<WaterTrackerWidget> {
  // Danh sách các trạng thái ly nước (true là đã uống, false là chưa uống)
  List<bool> _waterGlasses = List.generate(10, (index) => false);
  int _currentGlass = 0; // Ly nước hiện tại có dấu cộng
  int _oz = 0; // Tổng oz đã uống

  // Hàm cập nhật trạng thái khi nhấn vào dấu cộng
  void _drinkWater() {
    if (_currentGlass < _waterGlasses.length) {
      setState(() {
        _waterGlasses[_currentGlass] = true; // Đánh dấu ly hiện tại đã uống
        _currentGlass++; // Chuyển sang ly tiếp theo
        _oz += 8; // Mỗi ly là 8 oz
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và thông tin oz/ml
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Water",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$_oz oz / ${(_oz * 29.5735).toStringAsFixed(1)} ml",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Các ly/chai nước
              Wrap(
                spacing: 16.0, // Khoảng cách ngang
                runSpacing: 16.0, // Khoảng cách dọc
                children: List.generate(
                  _waterGlasses.length,
                  (index) {
                    return GestureDetector(
                      onTap: index == _currentGlass ? _drinkWater : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _waterGlasses[index]
                              ? Image.asset(
                                  'assets/glass.png',
                                  width: 50,
                                  height: 100,
                                )
                              : Image.asset(
                                  'assets/empty_glass.png',
                                  width: 50,
                                  height: 100,
                                ),
                          // Dấu cộng trên ly hiện tại
                          if (index == _currentGlass)
                            Icon(
                              Icons.add_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}