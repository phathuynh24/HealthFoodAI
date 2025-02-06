import 'package:app/widgets/separator.dart';
import 'package:flutter/material.dart';

class GoalItem extends StatelessWidget {
  final String title;        // Tiêu đề (e.g., "Weight Goals")
  final String value;        // Mục tiêu chính (e.g., "Gain Weight")
  final String subValue;     // Thông tin phụ (e.g., "Gain 0.5lbs per week")
  final String targetWeight; // Cân nặng hiện tại (e.g., "164lbs")
  final VoidCallback onTap;

  const GoalItem({
    Key? key,
    required this.title,
    required this.value,
    required this.subValue,
    required this.targetWeight,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Current Weight
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      targetWeight,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Separator(color: Colors.grey), // Phân cách
            const SizedBox(height: 8),

            // Goal & Weekly Target
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  subValue,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
