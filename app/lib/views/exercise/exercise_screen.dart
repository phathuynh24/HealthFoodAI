import 'package:app/core/theme/app_colors.dart';
import 'package:app/views/exercise/exercise_list_screen.dart';
import 'package:app/views/exercise/history_exercise_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class DailyWorkoutScreen extends StatefulWidget {
  const DailyWorkoutScreen({super.key});

  @override
  State<DailyWorkoutScreen> createState() => _DailyWorkoutScreenState();
}

class _DailyWorkoutScreenState extends State<DailyWorkoutScreen> {
  final beginnerWorkouts = [
    {
      'title': 'Bung Người Bắt Đầu',
      'time': '4 phút',
      'exercises': '5 bài tập',
      'image': 'assets/abs1.jpg',
      'type': 'Abs1',
    },
    {
      'title': 'Ngực Người Bắt Đầu',
      'time': '2 phút',
      'exercises': '2 bài tập',
      'image': 'assets/chest1.jpg',
      'type': 'Chest1',
    },
    {
      'title': 'Cánh Tay Người Bắt Đầu',
      'time': '5 phút',
      'exercises': '5 bài tập',
      'image': 'assets/arm1.jpg',
      'type': 'Arm1',
    },
    {
      'title': 'Chân Người Bắt Đầu',
      'time': '3 phút',
      'exercises': '4 bài tập',
      'image': 'assets/leg1.jpg',
      'type': 'Leg1',
    },
  ];

  final intermediateWorkouts = [
    {
      'title': 'Bung Trung Bình',
      'time': '4 phút',
      'exercises': '5 bài tập',
      'image': 'assets/abs2.jpg',
      'type': 'Abs2',
    },
    {
      'title': 'Ngực Trung Bình',
      'time': '6 phút',
      'exercises': '7 bài tập',
      'image': 'assets/chest2.jpg',
      'type': 'Chest2',
    },
    {
      'title': 'Cánh Tay Trung Bình',
      'time': '12 phút',
      'exercises': '18 bài tập',
      'image': 'assets/arm2.jpg',
      'type': 'Arm2',
    },
    {
      'title': 'Chân Trung Bình',
      'time': '5 phút',
      'exercises': '6 bài tập',
      'image': 'assets/leg2.jpg',
      'type': 'Leg2',
    },
  ];

  final advancedWorkouts = [
    {
      'title': 'Bung Nâng Cao',
      'time': '5 phút',
      'exercises': '6 bài tập',
      'image': 'assets/abs3.jpg',
      'type': 'Abs3',
    },
    {
      'title': 'Ngực Nâng Cao',
      'time': '5 phút',
      'exercises': '5 bài tập',
      'image': 'assets/chest3.jpg',
      'type': 'Chest3',
    },
    {
      'title': 'Cánh Tay Nâng Cao',
      'time': '3 phút',
      'exercises': '4 bài tập',
      'image': 'assets/arm3.jpg',
      'type': 'Arm3',
    },
    {
      'title': 'Chân Nâng Cao',
      'time': '3 phút',
      'exercises': '4 bài tập',
      'image': 'assets/leg3.jpg',
      'type': 'Leg3',
    },
  ];

  Widget buildWorkoutSection(
      String header, List<Map<String, String>> workouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            header,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ExerciseListScreen(filterType: workout['type']!),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(workout['image']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black
                          .withOpacity(0.3), // Tạo lớp phủ nhẹ để chữ rõ hơn
                      BlendMode.darken,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workout['time']} • ${workout['exercises']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black45,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;
    int daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "Tập luyện tại nhà"),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch sử tập trong tháng $currentMonth/$currentYear',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: daysInMonth,
                        itemBuilder: (context, index) {
                          DateTime day =
                              DateTime(currentYear, currentMonth, index + 1);
                          bool isToday = day.day == today.day &&
                              day.month == today.month &&
                              day.year == today.year;
                          bool isFuture = day.isAfter(today);

                          return GestureDetector(
                            onTap: isFuture
                                ? null
                                : () {
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HistoryExerciseScreen(
                                                initialDate: day),
                                      ),
                                    );
                                  },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? Colors.blue
                                    : isFuture
                                        ? Colors.grey.shade300
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                border: isToday
                                    ? Border.all(
                                        color: Colors.blueAccent, width: 2)
                                    : Border.all(color: Colors.grey.shade400),
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: isToday
                                        ? Colors.white
                                        : isFuture
                                            ? Colors.grey
                                            : Colors.black,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildWorkoutSection('Người Bắt Đầu', beginnerWorkouts),
                    const SizedBox(height: 16),
                    buildWorkoutSection('Trung Bình', intermediateWorkouts),
                    const SizedBox(height: 16),
                    buildWorkoutSection('Nâng Cao', advancedWorkouts),
                  ],
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}
