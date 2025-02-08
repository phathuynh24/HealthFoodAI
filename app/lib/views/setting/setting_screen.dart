import 'package:app/core/calorie_calculator/calorie_calculator.dart';
import 'package:app/core/events/calo_update_event.dart';
import 'package:app/core/events/event_bus.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/models/weight_model.dart';
import 'package:app/views/auth/login_screen.dart';
import 'package:app/views/setting/edit_goal_screen.dart';
import 'package:app/views/setting/list_weight_screen.dart';
import 'package:app/widgets/activity_level_picker_bottom_sheet.dart';
import 'package:app/widgets/custom_picker_bottom_sheet.dart';
import 'package:app/views/setting/add_weight_screen.dart';
import 'package:app/widgets/goal_achievement_dialog.dart';
import 'package:app/widgets/weight_chart.dart';
import 'package:app/widgets/weight_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String appVersion = "";

  final List<WeightModel> data = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getWeightHistory();
    _getAppVersion();
  }

  Future<void> _getWeightHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          List<dynamic> weightHistory =
              docSnapshot.data()?['weightHistory'] ?? [];

          // Chuyển dữ liệu từ Firestore thành List<WeightModel>
          List<WeightModel> historyData = weightHistory.map((entry) {
            return WeightModel(
              DateFormat('dd-MM-yyyy').parse(entry['date']),
              (entry['value'] as num).toDouble(),
            );
          }).toList();

          // Sắp xếp theo ngày (mới nhất ở cuối)
          historyData.sort((a, b) => a.date.compareTo(b.date));

          setState(() {
            data.clear();
            data.addAll(historyData);
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy lịch sử cân nặng: $e");
    }
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "Version ${packageInfo.version}";
    });
  }

  Future<void> _getUserData() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          setState(() {
            userData = docSnapshot.data();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu người dùng: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserData(String key, dynamic value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // 🔄 Cập nhật dữ liệu mới vào Firestore
        await docRef.update({key: value});

        // Cập nhật dữ liệu trên giao diện
        setState(() {
          userData?[key] = value;
        });

        // ✅ Tính toán lại lượng calo sau khi cập nhật thông tin
        await _recalculateCalories(docRef);
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật dữ liệu: $e');
    }
  }

  Future<void> _recalculateCalories(DocumentReference docRef) async {
    try {
      final gender = userData?['gender'];
      final weight = (userData?['weight'] ?? 0).toDouble();
      final height = userData?['height'];
      final age = userData?['age'];
      final activityLevel = userData?['activityLevel'];
      final goal = userData?['goal'];
      final weightChangeRate = (userData?['weightChangeRate'] ?? 0).toDouble();

      // ✅ Tính toán lại lượng calo
      final newCalories = CalorieCalculator.calculateDailyCalories(
        gender: gender,
        weight: weight,
        height: height,
        age: age,
        activityLevel: activityLevel,
        goal: goal,
        weightChangeRate: weightChangeRate,
      );

      // 🔄 Cập nhật lại dữ liệu calo trên Firestore
      await docRef.update({'calories': newCalories.round()});
      await updateSurveyHistoryToday(newCalories.round());

      // Cập nhật trực tiếp trên giao diện
      setState(() {
        userData?['calories'] = newCalories.round();
      });

      eventBus.fire(CaloUpdateEvent(newCalories.round()));

      debugPrint('Đã tính lại calo: $newCalories');
    } catch (e) {
      debugPrint('Lỗi khi tính lại lượng calo: $e');
    }
  }

  Future<void> updateSurveyHistoryToday(int calories) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final currentTimestamp = Timestamp.now();
        final todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

        // Lấy dữ liệu người dùng hiện tại từ Firestore
        final docSnapshot = await docRef.get();
        final surveyHistory =
            (docSnapshot.data()?['surveyHistory'] ?? []) as List;

        // Kiểm tra xem ngày hôm nay đã tồn tại chưa
        final existingIndex =
            surveyHistory.indexWhere((entry) => entry['date'] == todayDate);

        if (existingIndex != -1) {
          // Nếu đã tồn tại → Cập nhật lại calories và timestamp
          surveyHistory[existingIndex]['calories'] = calories;
          surveyHistory[existingIndex]['timestamp'] = currentTimestamp;
        } else {
          // Nếu chưa có → Thêm mới vào danh sách
          surveyHistory.add({
            'date': todayDate,
            'calories': calories,
            'timestamp': currentTimestamp,
          });
        }

        // 🔄 Cập nhật dữ liệu lên Firestore
        await docRef.update({'surveyHistory': surveyHistory});

        print('Đã cập nhật surveyHistory thành công!');
      }
    } catch (e) {
      print('Lỗi khi cập nhật surveyHistory: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAccountDetails(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Tài khoản', style: TextStyle(fontSize: 20)),
      centerTitle: true,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
    );
  }

  Future<void> _navigateAndAddWeight(Widget screen) async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result != null && result is Map<String, dynamic>) {
      final bool isList = result['isList'] ?? false;
      final bool hasReachedTarget = result['hasReachedTarget'] ?? false;

      setState(() {
        if (isList) {
          // 🗂️ Trường hợp 1: Dữ liệu trả về là danh sách cân nặng
          final List<WeightModel> sortedData = result['sortedData'] ?? [];

          for (var newWeight in sortedData) {
            _updateOrAddWeight(newWeight);
          }
        } else {
          // ⚡ Trường hợp 2: Dữ liệu trả về là một đối tượng cân nặng duy nhất
          final DateTime newDate =
              DateFormat('dd-MM-yyyy').parse(result['date']);
          final double newValue = result['value'];

          _updateOrAddWeight(WeightModel(newDate, newValue));
        }

        // 🔄 Sắp xếp dữ liệu từ ngày cũ đến ngày mới
        data.sort((a, b) => a.date.compareTo(b.date));

        // 🎯 Kiểm tra nếu đã đạt mục tiêu cân nặng
        if (hasReachedTarget) {
          getCurrentWeight().then((currentWeight) {
            showDialog(
              context: context,
              builder: (context) => GoalAchievementDialog(
                goal: userData?['goal'] ?? 0,
                goalWeight: userData?['targetWeight'] ?? 0,
                currentWeight: currentWeight, // ✅ Dữ liệu cân nặng hiện tại
                weeklyChange: userData?['weightChangeRate'] ?? 0,
                isSetNewGoal: false,
                onSetNewGoal: () {},
                onClose: () {
                  Navigator.pop(context);
                  _getUserData();
                  _getWeightHistory();
                },
              ),
            );
          });
        }
      });
    }
  }

  Future<double> getCurrentWeight() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

        final docSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          return (data?['weight'] ?? 0).toDouble(); // Lấy cân nặng từ Firestore
        }
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu cân nặng: $e');
    }
    return 0.0; // Trả về 0 nếu có lỗi hoặc không tìm thấy dữ liệu
  }

  void _updateOrAddWeight(WeightModel newWeight) {
    final existingIndex = data.indexWhere((item) =>
        DateFormat('dd-MM-yyyy').format(item.date) ==
        DateFormat('dd-MM-yyyy').format(newWeight.date));

    if (existingIndex != -1) {
      // Cập nhật giá trị nếu trùng ngày
      data[existingIndex] = newWeight;
    } else {
      // Thêm mới nếu chưa có
      data.add(newWeight);
    }

    // 🔄 Sắp xếp lại danh sách từ ngày cũ đến ngày mới
    data.sort((a, b) => a.date.compareTo(b.date));

    // 📌 Lấy dữ liệu cân nặng mới nhất (ngày gần nhất)
    final latestWeight = data.isNotEmpty ? data.last.weight : newWeight.weight;

    // ✅ Cập nhật vào userData
    userData?['weight'] = latestWeight;
  }

  Widget _buildAccountDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _navigateAndAddWeight(ListWeightScreen(
              data: data,
              userData: userData!,
            )),
            child: WeightTrackingChart(
              data: data, // Dữ liệu lịch sử cân nặng từ Firestore
              onAddWeight: () => _navigateAndAddWeight(const AddWeightScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildFeatureSection(
            items: [
              _buildFeatureItem(
                icon: CupertinoIcons.person_fill,
                color: Colors.blue,
                title: "Giới tính",
                subtitle: userData?['gender'] == "Male" ? "Nam" : "Nữ",
                onTap: () {
                  _showPicker(
                    context: context,
                    title: "Chọn Giới Tính",
                    options: ["Male", "Female"],
                    currentValue: userData?['gender'] ?? "Male",
                    onSelected: (value) => _updateUserData('gender', value),
                    displayValue: (value) => value == "Male" ? "Nam" : "Nữ",
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.height,
                color: Colors.red,
                title: "Chiều cao",
                subtitle: "${userData?['height'] ?? '--'} cm",
                onTap: () {
                  _showPicker(
                    context: context,
                    title: "Chọn Chiều Cao",
                    options: List.generate(
                        100, (index) => index + 100), // 100-200 cm
                    currentValue: userData?['height'] ?? 170,
                    onSelected: (value) => _updateUserData('height', value),
                    displayValue: (value) => "$value cm",
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.cake,
                color: Colors.indigo,
                title: "Tuổi",
                subtitle: "${userData?['age'] ?? '--'}",
                onTap: () {
                  _showPicker(
                    context: context,
                    title: "Chọn Tuổi",
                    options: List.generate(100, (index) => index + 1),
                    currentValue: userData?['age'] ?? 25,
                    onSelected: (value) => _updateUserData('age', value),
                  );
                },
              ),
              // _buildFeatureItem(
              //   icon: Icons.monitor_weight,
              //   color: Colors.orange,
              //   title: "Cân nặng",
              //   subtitle: "${userData?['weight'] ?? '--'} kg",
              //   onTap: () {
              //     showModalBottomSheet(
              //       context: context,
              //       shape: const RoundedRectangleBorder(
              //         borderRadius:
              //             BorderRadius.vertical(top: Radius.circular(20)),
              //       ),
              //       builder: (_) {
              //         return WeightPickerBottomSheet(
              //           initialWeight: (userData?['weight'] ?? 60).toDouble(),
              //           onSelected: (newWeight) {
              //             setState(() {
              //               userData?['weight'] = newWeight;
              //             });
              //             _updateUserData('weight', newWeight);
              //           },
              //         );
              //       },
              //     );
              //   },
              // ),
              _buildFeatureItem(
                icon: Icons.directions_run,
                color: Colors.green,
                title: "Hoạt động",
                subtitle: userData?['activityLevel'] ?? "Không rõ",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return ActivityLevelPickerBottomSheet(
                        selectedActivityLevel: userData?['activityLevel'] ??
                            "Không vận động nhiều",
                        onSelected: (value) {
                          _updateUserData('activityLevel', value);
                        },
                      );
                    },
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.flag,
                color: Colors.purple,
                title: "Mục tiêu",
                subtitle: userData?['goal'] ?? "Không rõ",
                showDivider: false,
                onTap: () async {
                  final updatedData =
                      await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const EditGoalScreen(),
                    ),
                  );

                  // Nếu có dữ liệu trả về thì cập nhật lại giao diện
                  if (updatedData != null && mounted) {
                    setState(() {
                      userData = updatedData;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildFeatureSection(
            items: [
              _buildFeatureItem(
                icon: Icons.info_outline,
                color: Colors.grey,
                title: "Phiên bản",
                subtitle: appVersion.isNotEmpty ? appVersion : "Đang tải...",
                onTap: () {},
              ),
              _buildFeatureItem(
                icon: Icons.logout,
                color: Colors.redAccent,
                title: "Đăng xuất",
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  void _showPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required T currentValue,
    required ValueChanged<T> onSelected,
    String Function(T)? displayValue,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return CustomPickerBottomSheet<T>(
          title: title,
          options: options,
          selectedValue: currentValue,
          onSelected: onSelected,
          displayValue: displayValue,
        );
      },
    );
  }

  Widget _buildFeatureSection({required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    String subtitle = "",
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color, size: 30),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 4,
            indent: 15,
            endIndent: 15,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}
