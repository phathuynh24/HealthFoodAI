import 'package:app/core/calorie_calculator/calorie_calculator.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/goal_achievement_dialog.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:app/widgets/separator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({Key? key}) : super(key: key);

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  double _weight = 63; // Mặc định nếu không có dữ liệu
  DateTime _selectedDate = DateTime.now();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _getLatestWeight(); // 🚀 Lấy cân nặng gần nhất khi mở màn hình
  }

  // 🗂️ Lấy dữ liệu cân nặng gần nhất
  Future<void> _getLatestWeight() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final weightHistory =
            (docSnapshot.data()?['weightHistory'] ?? []) as List;

        if (weightHistory.isNotEmpty) {
          // Sắp xếp danh sách theo ngày giảm dần
          weightHistory.sort((a, b) {
            final dateA = DateFormat('dd-MM-yyyy').parse(a['date']);
            final dateB = DateFormat('dd-MM-yyyy').parse(b['date']);
            return dateB.compareTo(dateA);
          });

          // Lấy giá trị cân nặng gần nhất
          setState(() {
            _weight = weightHistory.first['value'].toDouble();
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy lịch sử cân nặng: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024), // Ngày nhỏ nhất có thể chọn
      lastDate: DateTime.now(), // Giới hạn không cho chọn ngày tương lai
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // // Lưu lịch sử cân nặng
  // Future<void> _saveWeight() async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       setState(() {
  //         isSaving = true;
  //       });

  //       final uid = user.uid;
  //       final formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);

  //       final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

  //       final docSnapshot = await docRef.get();
  //       final weightHistory =
  //           (docSnapshot.data()?['weightHistory'] ?? []) as List;

  //       // Kiểm tra xem ngày đã tồn tại chưa
  //       bool dateExists = false;
  //       for (var entry in weightHistory) {
  //         if (entry['date'] == formattedDate) {
  //           entry['value'] = _weight; // Cập nhật nếu trùng ngày
  //           dateExists = true;
  //           break;
  //         }
  //       }

  //       // Thêm mới nếu chưa có
  //       if (!dateExists) {
  //         weightHistory.add({
  //           'date': formattedDate,
  //           'value': _weight,
  //         });
  //       }

  //       // Cập nhật Firestore
  //       await docRef.update({'weightHistory': weightHistory});

  //       // Trả dữ liệu mới về trang trước
  //       if (mounted) {
  //         Navigator.pop(context, {
  //           'date': formattedDate,
  //           'value': _weight,
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Lỗi khi lưu cân nặng: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isSaving = false;
  //       });
  //     }
  //   }
  // }

  // ✅ Kiểm tra xem đã đạt mục tiêu cân nặng chưa
  bool _hasReachedTarget(
      double currentWeight, double targetWeight, String goal) {
    if (goal == "Tăng cân") {
      return currentWeight >= targetWeight;
    } else if (goal == "Giảm cân") {
      return currentWeight <= targetWeight;
    }
    return false;
  }

  // ✅ Cập nhật dữ liệu người dùng trong Firestore
  Future<void> _updateUserData(
      String uid, double weight, double calories, String goal,
      {bool isMaintaining = false}) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    final updateData = {
      'weight': weight,
      'calories': calories,
      'updatedAt': Timestamp.now(),
    };

    debugPrint('isMaintaining: $isMaintaining');

    if (isMaintaining) {
      updateData['goal'] = 'Duy trì cân nặng';
      updateData['weightChangeRate'] = 0; // Không thay đổi cân nặng khi duy trì
      updateData['targetWeight'] = weight; // Mục tiêu cân nặng mới
    }

    debugPrint('updateData: $updateData');

    await docRef.update(updateData);
  }

  // ✅ Hàm lưu lịch sử cân nặng và xử lý logic
  Future<void> _saveWeight() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          isSaving = true;
        });

        final uid = user.uid;
        final formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
        final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final docSnapshot = await docRef.get();
        final userData = docSnapshot.data() ?? {};
        final weightHistory = (userData['weightHistory'] ?? []) as List;
        final targetWeight = (userData['targetWeight'] ?? 0).toDouble();
        final goal = userData['goal'];

        // 1️⃣ Kiểm tra xem ngày đã tồn tại chưa
        bool dateExists = false;
        for (var entry in weightHistory) {
          if (entry['date'] == formattedDate) {
            entry['value'] = _weight; // Cập nhật nếu trùng ngày
            dateExists = true;
            break;
          }
        }

        // 2️⃣ Thêm mới nếu chưa có
        if (!dateExists) {
          weightHistory.add({
            'date': formattedDate,
            'value': _weight,
          });
        }

        // 3️⃣ Cập nhật cân nặng hiện tại
        await docRef.update({'weightHistory': weightHistory});

        // 4️⃣ Kiểm tra xem đã đạt mục tiêu chưa
        final hasReachedTarget = _hasReachedTarget(_weight, targetWeight, goal);
        debugPrint('kkkk');
        // 5️⃣ Tính toán lại calo với CalorieCalculator
        final dailyCalories = CalorieCalculator.calculateDailyCalories(
          gender: userData['gender'],
          weight: _weight,
          height: userData['height'],
          age: userData['age'],
          activityLevel: userData['activityLevel'],
          goal: hasReachedTarget ? 'Duy trì cân nặng' : goal,
          weightChangeRate: hasReachedTarget
              ? 0.0
              : (userData['weightChangeRate'] as num).toDouble(),
        );
        // 6️⃣ Cập nhật dữ liệu người dùng
        await _updateUserData(uid, _weight, dailyCalories, goal,
            isMaintaining: hasReachedTarget);

        // 7️⃣ Trả dữ liệu mới về trang trước
        if (mounted) {
          Navigator.pop(context, {
            'date': formattedDate,
            'value': _weight,
            'hasReachedTarget': hasReachedTarget,
            'isList': false,
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lưu cân nặng: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            title: const Text('Ghi Nhận Cân Nặng'),
            actions: [
              TextButton(
                onPressed: _saveWeight, // Lưu dữ liệu khi nhấn nút "Lưu"
                child: const Text(
                  'Lưu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItem('Cân nặng', '${_weight.toStringAsFixed(1)} kg', () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Cân nặng của bạn'),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(hintText: 'Nhập cân nặng'),
                          onChanged: (value) {
                            setState(() {
                              _weight = double.tryParse(value) ?? _weight;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }),
                const SizedBox(height: 8),
                const Separator(color: Colors.grey),
                const SizedBox(height: 8),
                _buildItem(
                  'Ngày',
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  () => _selectDate(context),
                ),
              ],
            ),
          ),
        ),
        if (isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildItem(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
