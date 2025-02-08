import 'dart:io';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/models/meal_model.dart';
import 'package:app/views/main_screen.dart';
import 'package:app/views/food_recognition/food_scan_screen.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/health_rating_widgets.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class FoodDetailScreen extends StatefulWidget {
  final MealModel meal;
  final String imageUrl;
  final bool isFavorite;
  final bool isEditing;

  const FoodDetailScreen(
      {super.key,
      required this.meal,
      required this.imageUrl,
      this.isFavorite = false,
      this.isEditing = false});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final List<String> _fractionValues = ['1/4', '1/3', '1/2', '3/4'];
  final List<double> _fractionValuesNumeric = [0.25, 0.33, 0.5, 0.75];
  final TextEditingController _mealNameController = TextEditingController();
  String selectedMealType = 'Buổi sáng';
  late double _serving;
  late bool isFavorite;
  late bool isEditing;
  bool isLoggedMeal = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    _serving = widget.meal.serving;
    isEditing = widget.isEditing;
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    super.dispose();
  }

  String _formatServingValue(double serving) {
    if (serving < 1) {
      int index = _fractionValuesNumeric
          .indexWhere((value) => (value - serving).abs() < 0.01);
      return index != -1 ? _fractionValues[index] : serving.toStringAsFixed(2);
    }
    return serving.toInt().toString();
  }

  void _updateServing(bool isIncrement) {
    setState(() {
      if (isIncrement) {
        _serving = _serving < 1 ? _serving + 0.25 : _serving + 1;
      } else {
        if (_serving <= 0.25) return;
        _serving = _serving <= 1 ? _serving - 0.25 : _serving - 1;
      }
    });
  }

  Future<void> _editMeal() async {
    try {
      await FirebaseFirestore.instance
          .collection('logged_meals')
          .doc(widget.meal.id)
          .update({
        'calories': widget.meal.calories * _serving,
        'weight': widget.meal.weight * _serving,
        'serving': _serving,
      });

      // Thông báo thành công
      CustomSnackbar.show(context, "Đã cập nhật món ăn!", isSuccess: true);

      // Quay lại và trả dữ liệu cập nhật để màn hình trước load lại dữ liệu
      Navigator.pop(context, true);
    } catch (e) {
      CustomSnackbar.show(context, "Lỗi khi cập nhật: $e", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text('Chi tiết món ăn'),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.home,
                size: 28,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) =>
                      false, // Remove all routes in the stack, except Home Screen
                );
              },
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () async {
                  if (isFavorite) {
                    await _removeFavoriteMeal();
                  } else {
                    _showSaveMealDialog();
                  }
                },
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                label: Text(
                  isFavorite ? "Đã lưu" : "Lưu",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFavorite ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 16.0),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Image
                _buildMealImage(widget.imageUrl),
                const SizedBox(height: 16),
                // Name of the meal
                Text(
                  widget.meal.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Nutrition Estimate Table
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(132, 141, 185, 66),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Bảng dinh dưỡng",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            // IconButton(
                            //     onPressed: () => _showEditIngredientsModal(context),
                            //     icon: const SizedBox(child: Icon(Icons.edit))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Thành phần",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Trọng lượng",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Calories",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: _buildIngredients(
                            widget.meal.ingredients, _serving),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(child: Text("Tổng cộng")),
                            Expanded(
                                child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                  "${(widget.meal.weight * _serving).toStringAsFixed(0)} g"),
                            )),
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  "${(widget.meal.calories * _serving).toStringAsFixed(1)} Cal"),
                            )),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.grey),
                      Container(
                        color: Colors.yellow[100],
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dinh dưỡng",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...widget.meal.nutrients.map(
                              (nutrient) => _buildNutrientRow(
                                  nutrient.name, nutrient.amount),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildWarningWidget(warnings: widget.meal.warnings),
                const SizedBox(height: 16),
                HealthRatingWidget(
                  calories: widget.meal.calories,
                  protein: widget.meal.nutrients[0].amount,
                  carbs: widget.meal.nutrients[1].amount,
                  fat: widget.meal.nutrients[2].amount,
                  serving: _serving,
                  totalWeight: widget.meal.weight,
                ),
                const SizedBox(height: 16),

                /// Serving quantity selection
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Title
                      const Text(
                        "Chọn số lượng khẩu phần ăn",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Controls for increasing/decreasing serving
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Decrease button
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red, size: 28),
                            onPressed: () => _updateServing(false),
                          ),

                          /// Serving value display
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.green, width: 1.5),
                            ),
                            child: Text(
                              _formatServingValue(_serving),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),

                          /// Increase button
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green, size: 28),
                            onPressed: () => _updateServing(true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /// Retry Button
                    if (!isEditing)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FoodScanScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black54,
                            backgroundColor: Colors.lightBlue[100],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Thử lại",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    if (!isEditing) const SizedBox(width: 16),

                    /// Save to History Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isEditing) {
                            await _editMeal(); // Gọi hàm chỉnh sửa
                          } else {
                            final selectedMeal = await showDialog<String>(
                              context: context,
                              builder: (context) =>
                                  _buildMealSelectionDialog(context),
                            );

                            if (selectedMeal == null || selectedMeal.isEmpty)
                              return;

                            setState(() {
                              isLoggedMeal = true;
                            });

                            try {
                              await saveMealData(
                                context,
                                widget.meal,
                                widget.imageUrl,
                                _serving,
                                selectedMeal,
                                false,
                                "",
                              );
                              CustomSnackbar.show(
                                  context, 'Món ăn đã được lưu!',
                                  isSuccess: true);
                            } catch (e) {
                              CustomSnackbar.show(context, 'Lỗi khi lưu: $e',
                                  isSuccess: false);
                            } finally {
                              setState(() {
                                isLoggedMeal = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              isEditing ? Colors.green : Colors.yellow[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEditing ? "Lưu thay đổi" : "Thêm vào lịch sử",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isLoggedMeal)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildNutrientRow(String nutrient, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text((nutrient)),
          Text('${(amount * _serving).toStringAsFixed(1)} g'),
        ],
      ),
    );
  }

  void _checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;

    // Check if the meal is in the favorite list
    var snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('originalName', isEqualTo: widget.meal.name)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isFavorite = true; // Favorite meal
      });
    }
  }

  void _showSaveMealDialog() {
    // Set default value for meal name
    _mealNameController.text = widget.meal.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  "Lưu món ăn",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Input name
                TextField(
                  controller: _mealNameController,
                  decoration: const InputDecoration(
                    labelText: "Đặt tên riêng cho món ăn",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Button save
                ElevatedButton(
                  onPressed: () async {
                    if (_mealNameController.text.isEmpty) {
                      if (context.mounted) {
                        CustomSnackbar.show(
                            context, 'Vui lòng nhập tên món ăn!',
                            isSuccess: false);
                      }
                      return;
                    }

                    String? errorMessage;
                    bool isSaved = false;

                    try {
                      await saveMealData(
                        context,
                        widget.meal,
                        widget.imageUrl,
                        _serving,
                        "favorite",
                        true,
                        _mealNameController.text,
                      );
                      isSaved = true;
                    } catch (e) {
                      errorMessage = 'Lỗi khi lưu: $e';
                    }

                    if (!context.mounted) return;

                    // Đóng bottom sheet sau khi hoàn tất async
                    Navigator.pop(context);

                    if (isSaved) {
                      setState(() {
                        isFavorite = true;
                      });
                      CustomSnackbar.show(
                          context, 'Món ăn đã được lưu vào danh sách',
                          isSuccess: true);
                    } else if (errorMessage != null) {
                      CustomSnackbar.show(context, errorMessage,
                          isSuccess: false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Lưu món ăn"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> saveMealData(
    BuildContext context,
    dynamic meal,
    String imageUrl,
    double serving,
    String selectedMealType,
    bool isFavorite,
    String customName,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;
      DateTime now = DateTime.now();

      // Tạo ID tài liệu từ thời gian
      String docId = now.millisecondsSinceEpoch.toString();

      // Nếu món ăn đã được thêm vào danh sách yêu thích, không cần tải ảnh lên
      String finalImageUrl = "";
      if (meal.isFavorite) {
        finalImageUrl = meal.imageUrl;
      } else {
        //  // Upload image to Firebase Storage
        // String fileName = '${userId}_$docId.jpeg';
        // final storageRef =
        //     FirebaseStorage.instance.ref().child('meal_images/$fileName');
        // final metadata = SettableMetadata(
        //   contentType: 'image/jpeg',
        // );

        // File imageFile = File(meal.imageUrl);
        // final uploadTask = storageRef.putFile(imageFile, metadata);

        // // Wait for upload to complete and get download URL
        // final snapshot = await uploadTask.whenComplete(() => {});
        // finalImageUrl = await snapshot.ref.getDownloadURL();
      }

      // Create data for meal
      Map<String, dynamic> mealData = {
        'id': docId,
        'customName': isFavorite ? customName : meal.name,
        'originalName': meal.name,
        'calories': meal.calories,
        'weight': meal.weight,
        'nutrients': meal.nutrients
            .map((nutrient) => {
                  'name': nutrient.name,
                  'amount': nutrient.amount,
                })
            .toList(),
        'ingredients': meal.ingredients
            .map((ingredient) => {
                  'name_en': ingredient.nameEn,
                  'name_vi': ingredient.nameVi,
                  'quantity': ingredient.quantity,
                  'calories': ingredient.calories,
                })
            .toList(),
        'imageUrl': finalImageUrl,
        'userId': userId,
        'loggedAt': isFavorite ? null : DateFormat('yyyy-MM-dd').format(now),
        'type': isFavorite ? 'favorite' : selectedMealType,
        'isFavorite': isFavorite,
        'warnings': meal.warnings,
        'savedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
        'serving': serving,
      };

      // Collection name
      String collectionName = isFavorite ? 'favorite_meals' : 'logged_meals';

      // Add meal data to Firestore
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .set(mealData);

      // Lưu thông báo để hiển thị sau khi hoàn tất async
      String message = 'Món ăn đã được lưu thành công!';

      if (!context.mounted) return;

      CustomSnackbar.show(context, message, isSuccess: true);

      // Nếu món ăn KHÔNG phải là yêu thích, quay về màn hình chính và xóa lịch sử điều hướng
      if (!isFavorite) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false, // Xóa toàn bộ lịch sử điều hướng
        );
      }
    } catch (e) {
      debugPrint('Error saving meal: $e');
      String errorMessage = 'Đã xảy ra lỗi khi lưu món ăn: $e';

      if (!context.mounted) return;

      CustomSnackbar.show(context, errorMessage, isSuccess: false);
    }
  }

  Future<void> _removeFavoriteMeal() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;

      // Find the favorite meal
      var snapshot = await FirebaseFirestore.instance
          .collection('favorite_meals')
          .where('userId', isEqualTo: userId)
          .where('originalName', isEqualTo: widget.meal.name)
          .get();

      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance
            .collection('favorite_meals')
            .doc(doc.id)
            .delete();
      }

      // Update UI
      setState(() {
        isFavorite = false;
      });
      CustomSnackbar.show(context, 'Món ăn đã được xoá khỏi danh sách!',
          isSuccess: true);
    } catch (e) {
      // Show error message
      CustomSnackbar.show(
          context, 'Đã xảy ra lỗi khi xoá món ăn khỏi danh sách!',
          isSuccess: false);
    }
  }

  Widget _buildIngredients(List<IngredientModel> ingredients, double serving) {
    return Column(
      children: ingredients.map((ingredient) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(ingredient.nameVi),
            ),
            Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                      "${(ingredient.quantity * serving).toStringAsFixed(0)} g")),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                    "${(ingredient.calories * serving).toStringAsFixed(1)} Cal"),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildWarningWidget({required List<dynamic> warnings}) {
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return warnings.isEmpty
            ? const SizedBox()
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Có ${warnings.length} cảnh báo dinh dưỡng",
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded)
                      Column(
                        children: warnings.map((warning) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      warning,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildMealImage(String imageUrl) {
    final bool isNetworkImage = imageUrl.startsWith('http');
    final bool isLocalFile = File(imageUrl).existsSync();

    // Xác định ảnh hiển thị
    Widget imageWidget;
    if (isNetworkImage) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderImage(), // Hiển thị ảnh mặc định khi lỗi tải mạng
      );
    } else if (isLocalFile) {
      imageWidget = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = _buildPlaceholderImage(); // Hiển thị ảnh mặc định
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: imageWidget,
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/healthy_tip_1.png',
      fit: BoxFit.cover,
    );
  }

  Widget _buildMealSelectionDialog(BuildContext context) {
    String? selectedMealType; // Biến theo dõi bữa ăn được chọn

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            "Chọn buổi ăn",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMealOption(context, "Buổi sáng", selectedMealType, (meal) {
                setState(() {
                  selectedMealType = meal; // Cập nhật trạng thái khi chọn
                });
              }),
              _buildMealOption(context, "Buổi trưa", selectedMealType, (meal) {
                setState(() {
                  selectedMealType = meal;
                });
              }),
              _buildMealOption(context, "Buổi tối", selectedMealType, (meal) {
                setState(() {
                  selectedMealType = meal;
                });
              }),
              _buildMealOption(context, "Ăn vặt", selectedMealType, (meal) {
                setState(() {
                  selectedMealType = meal;
                });
              }),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                  ElevatedButton(
                    onPressed: selectedMealType == null
                        ? null // Không cho phép nhấn nếu chưa chọn
                        : () => Navigator.pop(context, selectedMealType),
                    child: const Text("Xác nhận"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealOption(BuildContext context, String mealType,
      String? selectedMealType, Function(String) onSelected) {
    bool isSelected = selectedMealType == mealType;

    return GestureDetector(
      onTap: () => onSelected(mealType), // Gọi hàm callback để cập nhật
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[700] : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            mealType,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
