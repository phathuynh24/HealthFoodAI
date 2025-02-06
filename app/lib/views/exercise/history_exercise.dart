import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryExercise extends StatefulWidget {
  @override
  _HistoryExerciseState createState() => _HistoryExerciseState();
}

class _HistoryExerciseState extends State<HistoryExercise> {
  DateTime? selectedDay;
  List<Map<String, dynamic>> exercises = [];
  List<Map<String, dynamic>> dailyExercises = [];

  @override
  void initState() {
    super.initState();
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
      return bDate.compareTo(aDate); // Newest first
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
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Lịch sử bài tập'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: selectedDay ?? DateTime.now(),
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) =>
                    selectedDay != null && isSameDay(selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                  });
                  filterExercisesByDay(selected);
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Bài tập trong ngày:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              dailyExercises.isEmpty
                  ? Center(child: Text('Không có bài tập nào trong ngày này.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: dailyExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = dailyExercises[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.fitness_center, size: 50),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise['name'] ?? 'Không có tên',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Thời gian: ${exercise['duration']} giây',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                    Text(
                                      'Hoàn thành: ${exercise['completed_at']}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ],
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