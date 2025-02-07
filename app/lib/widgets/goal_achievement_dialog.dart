import 'package:flutter/material.dart';

class GoalAchievementDialog extends StatelessWidget {
  final String goal;
  final double goalWeight;
  final double currentWeight;
  final double weeklyChange;
  final VoidCallback onSetNewGoal;
  final VoidCallback onClose;
  final bool isSetNewGoal;

  const GoalAchievementDialog({
    Key? key,
    required this.goal,
    required this.goalWeight,
    required this.currentWeight,
    required this.weeklyChange,
    required this.onClose,
    required this.onSetNewGoal,
    this.isSetNewGoal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 10),
            const Text(
              'Chúc mừng!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cân nặng mục tiêu của bạn là ${goalWeight.toStringAsFixed(1)} kg, và cân nặng gần nhất là ${currentWeight.toStringAsFixed(1)} kg. Bạn đã đạt được mục tiêu của mình!\n\nKế hoạch $goal ${weeklyChange.toStringAsFixed(1)} kg mỗi tuần sẽ bị tạm dừng và lượng calo cơ bản sẽ được tính lại.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            if (isSetNewGoal)
              ElevatedButton(
                onPressed: onSetNewGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Đặt Mục Tiêu Mới',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            if (isSetNewGoal) const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Đóng',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
