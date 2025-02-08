import 'package:app/core/events/calo_update_event.dart';
import 'package:app/core/events/event_bus.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/models/meal_model.dart';
import 'package:app/views/food_recognition/food_detail_screen.dart';
import 'package:app/views/food_recognition/food_scan_screen.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:app/widgets/separator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  int remainingCalories = 0;
  int goalCalories = 0;
  int consumedCalories = 0;
  double totalCarbs = 0;
  double totalProtein = 0;
  double totalFat = 0;
  List<Map<String, dynamic>> meals = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDataForDate(selectedDate);

    eventBus.on<CaloUpdateEvent>().listen((event) {
      setState(() {
        goalCalories = event.calo;
      });
      loadDataForDate(selectedDate);
    });
  }

  Future<void> loadDataForDate(DateTime date) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          isLoading = true;
        });

        final uid = user.uid;
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        final userData = userDoc.data();
        final surveyHistory = userData?['surveyHistory'] ?? [];
        final createdAt = (userData?['createdAt'] as Timestamp).toDate();

        // ✅ Giới hạn không cho chọn ngày trước createdAt
        if (date.isBefore(createdAt)) {
          if (mounted) {
            CustomSnackbar.show(
                context, "Không có dữ liệu trước ngày tạo tài khoản!",
                isSuccess: false);
          }
          return;
        }

        // ✅ Chặn chọn ngày trong tương lai
        if (date.isAfter(DateTime.now())) {
          if (mounted) {
            CustomSnackbar.show(context, "Không thể chọn ngày trong tương lai!",
                isSuccess: false);
          }
          return;
        }

        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        // ✅ Xác định goalCalories
        if (isToday(date)) {
          goalCalories = (userData?['calories'] ?? 0).toInt();
        } else {
          final previousSurvey = surveyHistory
              .where((entry) =>
                  DateFormat('dd-MM-yyyy').parse(entry['date']).isBefore(date))
              .toList()
            ..sort((a, b) => DateFormat('dd-MM-yyyy')
                .parse(b['date'])
                .compareTo(DateFormat('dd-MM-yyyy').parse(a['date'])));

          if (previousSurvey.isNotEmpty) {
            goalCalories = (previousSurvey.first['calories'] ?? 0).toInt();
          } else {
            goalCalories = 0;
          }
        }

        final mealsSnapshot = await FirebaseFirestore.instance
            .collection('logged_meals')
            .where('userId', isEqualTo: uid)
            .where('loggedAt', isEqualTo: dateKey)
            .get();

        meals = mealsSnapshot.docs.map((doc) => doc.data()).toList();

        // Tính tổng calo đã tiêu thụ và các chỉ số dinh dưỡng
        consumedCalories = 0;
        totalCarbs = 0;
        totalProtein = 0;
        totalFat = 0;

        for (var meal in meals) {
          consumedCalories += (meal['calories'] as num).toInt();

          if (meal['nutrients'] != null) {
            List<dynamic> nutrients = meal['nutrients'];

            for (var nutrient in nutrients) {
              switch (nutrient['name']) {
                case 'Carbohydrate':
                  totalCarbs += (nutrient['amount'] as num).toDouble();
                  break;
                case 'Protein':
                  totalProtein += (nutrient['amount'] as num).toDouble();
                  break;
                case 'Chất béo':
                  totalFat += (nutrient['amount'] as num).toDouble();
                  break;
              }
            }
          }
        }

        // ✅ Tính toán lại consumedCalories
        consumedCalories = meals.fold(0, (int sum, item) {
          final calories = item['calories'];

          if (calories is int) {
            return sum + calories;
          } else if (calories is double) {
            return sum + calories.round();
          } else {
            return sum;
          }
        });

        remainingCalories = goalCalories - consumedCalories;

        setState(() {
          selectedDate = date;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi load dữ liệu: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Hàm kiểm tra xem có phải hôm nay không
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      await FirebaseFirestore.instance
          .collection('logged_meals')
          .doc(mealId)
          .delete();

      // Tải lại dữ liệu sau khi xóa thành công
      loadDataForDate(selectedDate);
    } catch (e) {
      debugPrint("Lỗi khi xóa món ăn: $e");
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Center(
        child: Text(
          isToday(selectedDate)
              ? "Hôm nay"
              : DateFormat('EEEE, d-M-yyyy', 'vi').format(selectedDate),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () async {
          final newDate = selectedDate.subtract(const Duration(days: 1));
          await loadDataForDate(newDate);
        },
      ),
      actions: [
        IconButton(
          icon:
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          onPressed: () async {
            final newDate = selectedDate.add(const Duration(days: 1));
            await loadDataForDate(newDate);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCalorieDisplay(),
                const SizedBox(height: 16),
                _buildContent(),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildCalorieDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Calories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Lượng calo còn lại = Mục tiêu - Thức ăn"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularCalorieDisplay(consumedCalories),
                  _buildCalorieDetails(),
                ],
              ),
              SizedBox(
                  height: 40, child: Separator(color: Colors.grey.shade400)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutrientInfo(
                      "Carbs", "${totalCarbs.toStringAsFixed(1)} g"),
                  _buildNutrientInfo(
                      "Protein", "${totalProtein.toStringAsFixed(1)} g"),
                  _buildNutrientInfo("Fat", "${totalFat.toStringAsFixed(1)} g"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularCalorieDisplay(int totalCalories) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: goalCalories == 0 ? 0 : consumedCalories / goalCalories,
                strokeWidth: 8,
                color: Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
              Center(
                child: Text(
                  '${remainingCalories.toInt()}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text("Còn lại"),
      ],
    );
  }

  Widget _buildCalorieDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orange),
            const SizedBox(width: 4),
            Text("Mục tiêu: $goalCalories Cal"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.blue),
            const SizedBox(width: 4),
            Text("Ăn uống: $consumedCalories Cal"),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientInfo(String nutrient, String value) {
    return Column(
      children: [
        Text(nutrient, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          _buildMealTypeSection(
              "Buổi sáng", Icons.breakfast_dining, "Buổi sáng"),
          _buildMealTypeSection("Buổi trưa", Icons.lunch_dining, "Buổi trưa"),
          _buildMealTypeSection("Buổi tối", Icons.dinner_dining, "Buổi tối"),
          _buildMealTypeSection("Ăn vặt", Icons.fastfood, "Ăn vặt"),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection(String title, IconData icon, String mealType) {
    final mealList = meals.where((meal) => meal['type'] == mealType).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.orange, size: 30),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const FoodScanScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add_circle, color: Colors.green)),
          ),
        ),
        ...mealList.map((meal) {
          String id = meal['id'] ?? '';
          String imageUrl = meal['imageUrl'] ?? '';
          String name = meal['customName'] ?? meal['originalName'];
          double calories = meal['calories'] ?? 0;
          double weight = meal['weight'] ?? 0;

          return GestureDetector(
            onTap: () async {
              final result =
                  await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(
                    meal: MealModel.fromMap(meal),
                    imageUrl: imageUrl,
                    isEditing: true,
                  ),
                ),
              );

              if (result == true) {
                loadDataForDate(
                    selectedDate); // Load lại dữ liệu nếu đã chỉnh sửa
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/dish_icon.png',
                            width: 68,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Calories: $calories kcal",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        "Khối lượng: $weight g",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Xác nhận"),
                            content: const Text(
                                "Bạn có chắc muốn xóa món ăn này không?"),
                            actions: [
                              TextButton(
                                child: const Text("Hủy"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text("Xóa",
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await deleteMeal(id);
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Xóa"),
                      ),
                    ],
                  )),
            ),
          );
        }),
      ],
    );
  }
}
