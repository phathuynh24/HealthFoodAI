import 'package:flutter/material.dart';

class ActivityLevelPickerBottomSheet extends StatefulWidget {
  final String selectedActivityLevel;
  final ValueChanged<String> onSelected;

  const ActivityLevelPickerBottomSheet({
    Key? key,
    required this.selectedActivityLevel,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<ActivityLevelPickerBottomSheet> createState() =>
      _ActivityLevelPickerBottomSheetState();
}

class _ActivityLevelPickerBottomSheetState
    extends State<ActivityLevelPickerBottomSheet> {
  late String selectedActivity;

  final List<Map<String, dynamic>> activityLevels = [
    {
      "level": "Không vận động nhiều",
      "description": "Ít hoạt động, thường làm việc văn phòng hoặc ngồi nhiều.",
      "calories": 1800,
    },
    {
      "level": "Hơi vận động",
      "description": "Hoạt động nhẹ nhàng hàng ngày như đi bộ, làm việc nhà.",
      "calories": 2000,
    },
    {
      "level": "Vận động vừa phải",
      "description": "Vận động thường xuyên như đi xe đạp, tập thể dục nhẹ.",
      "calories": 2300,
    },
    {
      "level": "Vận động nhiều",
      "description": "Hoạt động thể chất cường độ cao như chạy bộ, thể hình.",
      "calories": 2600,
    },
    {
      "level": "Vận động rất nhiều",
      "description": "Làm việc nặng hoặc vận động cường độ rất cao hàng ngày.",
      "calories": 2900,
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.selectedActivityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Cancel - Title - Save
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
              ),
              const Text("Mức độ hoạt động", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () {
                  widget.onSelected(selectedActivity);
                  Navigator.pop(context);
                },
                child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          ...activityLevels.map((activity) {
            final isSelected = activity['level'] == selectedActivity;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedActivity = activity['level'];
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: Colors.green, width: 2)
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['level'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected ? Colors.green : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['description'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}
