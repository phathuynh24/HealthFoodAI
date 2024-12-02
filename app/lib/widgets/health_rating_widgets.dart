import 'package:flutter/material.dart';

class HealthRatingWidget extends StatelessWidget {
  final double healthRating; // Giá trị từ 0.0 đến 1.0 cho chỉ số sức khỏe

  HealthRatingWidget({required this.healthRating});

  @override
  Widget build(BuildContext context) {
    double barWidth =
        MediaQuery.of(context).size.width * 0.8; // Chiều rộng của thanh
    double indicatorPosition = healthRating * barWidth;

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Health Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: barWidth,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(
                  colors: [
                    Colors.red, // Bad
                    Colors.orange, // Poor
                    Colors.yellow, // Good
                    Colors.lightGreen, // Great
                    Colors.green, // Excellent
                  ],
                  stops: [0.2, 0.4, 0.6, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              left: indicatorPosition,
              child: Transform.scale(
                scale: 2.5,
                child: Icon(
                  Icons.arrow_drop_up,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bad', style: TextStyle(fontSize: 12)),
            Text('Poor', style: TextStyle(fontSize: 12)),
            Text('Good', style: TextStyle(fontSize: 12)),
            Text('Great', style: TextStyle(fontSize: 12)),
            Text('Excellent', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}