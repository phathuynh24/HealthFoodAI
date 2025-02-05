import 'dart:io';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/models/meal_model.dart';
import 'package:app/views/main_screen.dart';
import 'package:app/views/meals/favorite_meals.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/health_rating_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FoodDetailScreen extends StatefulWidget {
  final MealModel meal;
  final String imageUrl;
  final bool isFavorite;

  const FoodDetailScreen(
      {super.key,
      required this.meal,
      required this.imageUrl,
      this.isFavorite = false});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final List<String> _fractionValues = ['1/4', '1/3', '1/2', '3/4'];
  final List<double> _fractionValuesNumeric = [0.25, 0.33, 0.5, 0.75];
  final TextEditingController _mealNameController = TextEditingController();
  String selectedMealType = 'Buổi sáng';
  double _serving = 1;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
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

  void _showEditIngredientsModal(BuildContext context) {
    List<TextEditingController> nameControllers = widget.meal.ingredients
        .map((ingredient) => TextEditingController(text: ingredient.nameVi))
        .toList();
    List<TextEditingController> caloriesControllers = widget.meal.ingredients
        .map((ingredient) =>
            TextEditingController(text: ingredient.calories.toString()))
        .toList();
    List<TextEditingController> quantitiesControllers = widget.meal.ingredients
        .map((ingredient) =>
            TextEditingController(text: ingredient.quantity.toString()))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Hủy",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    const Text(
                      "Chỉnh sửa",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        List<IngredientModel> updatedIngredients = [];
                        for (int i = 0; i < nameControllers.length; i++) {
                          updatedIngredients.add(
                            IngredientModel(
                              nameVi: nameControllers[i].text,
                              calories: double.tryParse(
                                      caloriesControllers[i].text) ??
                                  0,
                              quantity: double.tryParse(
                                      quantitiesControllers[i].text) ??
                                  0.0,
                              nameEn: nameControllers[i].text,
                            ),
                          );
                        }

                        // setState(() {
                        //   widget.meal.ingredients = updatedIngredients
                        //       .map((ingredient) => IngredientModel(
                        //             nameVi: ingredient.nameVi,
                        //             nameEn: ingredient.nameEn,
                        //             calories: ingredient.calories,
                        //             quantity: ingredient.quantity,
                        //           ))
                        //       .toList();
                        // });

                        Navigator.pop(context);
                      },
                      child: const Text("Regenerate",
                          style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: nameControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cột Name
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: nameControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Cột Calories
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: caloriesControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Calories',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Cột Quantity
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: quantitiesControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Chi tiết món ăn'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, size: 28,),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false, // Remove all routes in the stack, except Home Screen
            );
          },
        ),
        actions: [
          // Container(
          //   margin: const EdgeInsets.only(right: 16.0),
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(8.0),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.grey.withOpacity(0.3),
          //         blurRadius: 4,
          //         offset: const Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: DropdownButton<String>(
          //     value: selectedMealType,
          //     hint: const Text(
          //       "Chọn buổi",
          //       style:
          //           TextStyle(color: Colors.white, fontSize: 14.0),
          //     ),
          //     dropdownColor: Colors.white,
          //     items: ['Buổi sáng', 'Buổi trưa', 'Buổi tối', 'Ăn vặt']
          //         .map((type) => DropdownMenuItem<String>(
          //               value: type,
          //               child: Text(
          //                 type,
          //                 style: const TextStyle(
          //                   color: Colors.black87,
          //                   fontSize: 14.0,
          //                 ),
          //               ),
          //             ))
          //         .toList(),
          //     onChanged: (value) {
          //       setState(() {
          //         selectedMealType = value!;
          //       });
          //     },
          //     style: const TextStyle(
          //         color: Colors.white),
          //     iconEnabledColor: Colors.black87,
          //     underline: const SizedBox(),
          //     isDense: true,
          //   ),
          // ),
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
            // Image
            if (widget.imageUrl.startsWith('http'))
              Container(
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
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Text('Không tải được ảnh mạng')),
                  ),
                ),
              )
            else if (File(widget.imageUrl).existsSync())
              Container(
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
                  child: Image.file(
                    File(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              const SizedBox(
                height: 150,
                child: Center(
                  child: Text('Không có ảnh'),
                ),
              ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bảng dinh dưỡng",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                            onPressed: () => _showEditIngredientsModal(context),
                            icon: const SizedBox(child: Icon(Icons.edit))),
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
                    child: _buildIngredients(widget.meal.ingredients, _serving),
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
                              "${(widget.meal.weight * _serving).toStringAsFixed(1)} g"),
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
                          "Nutrient",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ...widget.meal.nutrients.map(
                          (nutrient) =>
                              _buildNutrientRow(nutrient.name, nutrient.amount),
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
              healthRating: (0.3 +
                  (0.7 - 0.3) *
                      (DateTime.now().millisecondsSinceEpoch % 1000) /
                      1000),
            ),
            const SizedBox(height: 16),
            const Text(
              "Số lượng (Serving)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateServing(false),
                ),
                Text(
                  _formatServingValue(_serving),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateServing(true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  child: const Text("Thử lại"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await saveMealData(
                        context,
                        widget.meal,
                        widget.imageUrl,
                        _serving,
                        selectedMealType,
                        false, // isFavorite = false -> log meal
                        "", // Log meal without custom name
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi lưu món ăn: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.yellow[700],
                  ),
                  child: const Text("Lưu vào nhật ký"),
                ),
              ],
            ),
          ],
        ),
      ),
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
                // Tittle
                const Text(
                  "Lưu món ăn yêu thích",
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
                    if (_mealNameController.text.isNotEmpty) {
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
                      } catch (e) {
                        CustomSnackbar.show(context, 'Lỗi khi lưu: $e',
                            isSuccess: false);
                      }
                      Navigator.pop(context);
                      setState(() {
                        isFavorite = true;
                      });

                      CustomSnackbar.show(context,
                          'Món ăn đã được thêm vào danh sách yêu thích!',
                          isSuccess: true);
                    } else {
                      CustomSnackbar.show(context, 'Vui lòng nhập tên món ăn!',
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
      if (user == null) {
        return;
      }

      String userId = user.uid;
      DateTime now = DateTime.now();

      // Tạo ID tài liệu từ thời gian
      String docId = now.millisecondsSinceEpoch.toString();

      // Nếu món ăn đã được thêm vào danh sách yêu thích, không cần tải ảnh lên
      var imageUrl = "";
      if (widget.isFavorite) {
        imageUrl = widget.imageUrl;
      } else {
        // Upload image to Firebase Storage
        String fileName = '${userId}_$docId.jpeg';
        final storageRef =
            FirebaseStorage.instance.ref().child('meal_images/$fileName');
        final metadata = SettableMetadata(
          contentType: 'image/jpeg', // Đảm bảo loại MIME chính xác
        );
        File imageFile = File(widget.imageUrl);
        final uploadTask = storageRef.putFile(imageFile, metadata);

        // Wait for upload to complete and get download URL
        final snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Create data for meal
      Map<String, dynamic> mealData = {
        'customName': isFavorite ? customName : meal.name, // User-defined name
        'originalName': meal.name, // Default name
        'calories': meal.calories * serving,
        'weight': meal.weight * serving,
        'nutrients': meal.nutrients
            .map((nutrient) => {
                  'name': nutrient.name,
                  'amount': nutrient.amount * serving,
                })
            .toList(),
        'ingredients': meal.ingredients
            .map((ingredient) => {
                  'name_en': ingredient.name_en,
                  'name_vi': ingredient.name_vi,
                  'quantity': ingredient.quantity * serving,
                  'calories': ingredient.calories * serving,
                })
            .toList(),
        'imageUrl': imageUrl, // URL tải xuống từ Firebase Storage
        'userId': userId,
        'loggedAt': isFavorite
            ? null
            : DateFormat('yyyy-MM-dd')
                .format(now), // Date when the meal is logged
        'type': isFavorite ? 'favorite' : selectedMealType, // Meal type
        'isFavorite': isFavorite,
        'warnings': meal.warnings,
        'savedAt':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(now), // Date when saved
      };

      // Collection name
      String collectionName = isFavorite ? 'favorite_meals' : 'logged_meals';

      // Add meal data to Firestore with docId
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .set(mealData);

      // Show success message
      CustomSnackbar.show(context, 'Món ăn đã được lưu thành công!',
          isSuccess: true);
    } catch (e) {
      // Show error message
      CustomSnackbar.show(context, 'Đã xảy ra lỗi khi lưu món ăn: $e',
          isSuccess: false);
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

      CustomSnackbar.show(
          context, 'Món ăn đã được xoá khỏi danh sách yêu thích!',
          isSuccess: true);
    } catch (e) {
      // Show error message
      CustomSnackbar.show(
          context, 'Đã xảy ra lỗi khi xoá món ăn khỏi danh sách yêu thích!',
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
                  child: Text("${(ingredient.quantity * serving)} g")),
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
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Món ăn này an toàn và phù hợp với sức khỏe.",
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
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
}
