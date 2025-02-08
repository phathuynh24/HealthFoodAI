import 'package:app/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryExerciseScreen extends StatefulWidget {
  final DateTime? initialDate;
  const HistoryExerciseScreen({super.key, this.initialDate});

  @override
  State<HistoryExerciseScreen> createState() => _HistoryExerciseScreenState();
}

class _HistoryExerciseScreenState extends State<HistoryExerciseScreen> {
  DateTime? selectedDay;
  List<Map<String, dynamic>> exercises = [];
  List<Map<String, dynamic>> dailyExercises = [];

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate ?? DateTime.now();
    getExerciseData();
  }

  void getExerciseData() async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    QuerySnapshot querySnapshot = await firestore
        .collection('completed_exercises')
        .where('user_uid', isEqualTo: currentUser.uid)
        .get();

    setState(() {
      exercises = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
      sortExercisesByDate();
      if (selectedDay != null) {
        filterExercisesByDay(selectedDay!);
      }
    });
  }

  void sortExercisesByDate() {
    exercises.sort((a, b) {
      final aDate = parseDate(a['completed_at']);
      final bDate = parseDate(b['completed_at']);
      return bDate.compareTo(aDate);
    });
  }

  DateTime parseDate(String date) {
    final parts = date.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void filterExercisesByDay(DateTime day) {
    setState(() {
      dailyExercises = exercises.where((exercise) {
        final completedAt = parseDate(exercise['completed_at']);
        return isSameDay(completedAt, day);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    CalendarFormat calendarFormat = CalendarFormat.month;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Lịch sử bài tập'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                locale: 'vi_VN',
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.now(),
                focusedDay: selectedDay ?? DateTime.now(),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Tháng',
                  CalendarFormat.week: 'Tuần',
                }, // Chỉ hiển thị các tùy chọn Tháng và Tuần
                onFormatChanged: (format) {
                  setState(() {
                    calendarFormat =
                        format; // Cập nhật định dạng lịch khi thay đổi
                  });
                },
                selectedDayPredicate: (day) =>
                    selectedDay != null && isSameDay(selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                  });
                  filterExercisesByDay(selected);
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Bài tập trong ngày:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              dailyExercises.isEmpty
                  ? const Center(
                      child: Text('Không có bài tập nào trong ngày này.'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dailyExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = dailyExercises[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center,
                                  size: 40, color: Colors.blueAccent),
                              title: Text(
                                exercise['name'] ?? 'Không có tên',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4.0),
                                  Text(
                                      'Thời gian: ${exercise['duration']} giây'),
                                  // Text('Hoàn thành: ${exercise['completed_at']}'),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
