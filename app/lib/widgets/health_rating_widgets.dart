import 'package:flutter/material.dart';

class HealthRatingWidget extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double serving;
  final double totalWeight;

  const HealthRatingWidget({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.serving,
    required this.totalWeight,
  });

  double calculateHealthRating() {
    // Tính toán lượng dinh dưỡng theo khẩu phần
    double adjustedCalories = (calories / totalWeight) * 100 * serving;
    double adjustedProtein = (protein / totalWeight) * 100 * serving;
    double adjustedCarbs = (carbs / totalWeight) * 100 * serving;
    double adjustedFat = (fat / totalWeight) * 100 * serving;

    // Ngưỡng tối thiểu và tối đa của các chỉ số
    double minCal = 0, maxCal = 8000;
    double minFat = 0, maxFat = 100;
    double minCarbs = 0, maxCarbs = 300;
    double minProtein = 0, maxProtein = 100;

    // Chuẩn hóa giá trị về thang 0 - 1
    double calScore =
        (1 - ((adjustedCalories - minCal) / (maxCal - minCal))).clamp(0.0, 1.0);
    double fatScore =
        (1 - ((adjustedFat - minFat) / (maxFat - minFat))).clamp(0.0, 1.0);
    double carbsScore =
        (1 - ((adjustedCarbs - minCarbs) / (maxCarbs - minCarbs)))
            .clamp(0.0, 1.0);
    double proteinScore =
        ((adjustedProtein - minProtein) / (maxProtein - minProtein))
            .clamp(0.0, 1.0);

    // Tính điểm trung bình (trọng số có thể thay đổi)
    return (calScore * 0.4 +
            fatScore * 0.2 +
            carbsScore * 0.2 +
            proteinScore * 0.2)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    double barWidth = MediaQuery.of(context).size.width - 40;
    double healthRating = calculateHealthRating();
    double indicatorPosition = healthRating * barWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Món ăn này có tốt cho sức khỏe không?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: barWidth,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.lightGreen,
                    Colors.green,
                  ],
                  stops: [0.2, 0.4, 0.6, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              left: indicatorPosition.clamp(0, barWidth - 10),
              child: Transform.scale(
                scale: 2.5,
                child: const Icon(
                  Icons.arrow_drop_up,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rất kém',
                style: TextStyle(fontSize: 12, color: Colors.red)), // Bad
            Text('Kém',
                style: TextStyle(fontSize: 12, color: Colors.deepOrange)), // Poor
            Text('Bình thường',
                style: TextStyle(fontSize: 12, color: Colors.orangeAccent)), // Good
            Text('Tốt',
                style:
                    TextStyle(fontSize: 12, color: Colors.lightGreen)), // Great
            Text('Xuất sắc',
                style:
                    TextStyle(fontSize: 12, color: Colors.green)), // Excellent
          ],
        ),
      ],
    );
  }
}
