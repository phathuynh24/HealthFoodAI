import 'dart:io';
import 'dart:convert';
import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/food_recognition/food_detail_screen.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/models/meal_model.dart';
import 'package:app/core/network/api_constants.dart';

class FoodReviewScreen extends StatefulWidget {
  final File image;

  const FoodReviewScreen({super.key, required this.image});

  @override
  State<FoodReviewScreen> createState() => _FoodReviewScreenState();
}

class _FoodReviewScreenState extends State<FoodReviewScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  bool isLoading = false;
  bool isHealthInfoEntered = false;

  Future<void> uploadImage() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(ApiConstants.getPredictNutritionUrl());
      var request = http.MultipartRequest('POST', url)
        ..files
            .add(await http.MultipartFile.fromPath('image', widget.image.path))
        ..fields[MealFields.description] = _descriptionController.text;

      // Nếu có dữ liệu về đường huyết, thêm vào request
      if (_bloodSugarController.text.isNotEmpty) {
        request.fields[MealFields.bloodSugar] = _bloodSugarController.text;
      }

      // Nếu có dữ liệu về huyết áp, thêm vào request
      if (_systolicController.text.isNotEmpty &&
          _diastolicController.text.isNotEmpty) {
        request.fields[MealFields.bloodPressure] = jsonEncode({
          "systolic": int.tryParse(_systolicController.text) ?? 0,
          "diastolic": int.tryParse(_diastolicController.text) ?? 0,
        });
      }

      // Gửi request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      debugPrint("Response: $data");

      if (!mounted) return;

      if (response.statusCode == 200) {
        _handleApiResponse(context, data);
      } else {
        CustomSnackbar.show(context, "Lỗi: ${response.reasonPhrase}",
            isSuccess: false);
      }
    } catch (e) {
      if (e is SocketException) {
        CustomSnackbar.show(context, "Không thể kết nối đến máy chủ!",
            isSuccess: false);
      } else {
        CustomSnackbar.show(context, "Lỗi khi tải lên ảnh: $e",
            isSuccess: false);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleApiResponse(BuildContext context, Map<String, dynamic> data) {
    if (data.containsKey("predictions_model")) {
      _processPredictionModel(context, data);
    } else if (data.containsKey("gemini_result")) {
      _processGeminiModel(context, data);
    } else {
      CustomSnackbar.show(context, "Không thể xác định món ăn!",
          isSuccess: false);
    }
  }

  void _processPredictionModel(
      BuildContext context, Map<String, dynamic> data) {
    var foodName = data[MealFields.predictedName] ?? "Món ăn chưa xác định";
    double calories =
        (data["nutrition_info"][MealFields.calories] as num?)?.toDouble() ??
            0.0;
    double protein =
        (data["nutrition_info"][NutritionFields.protein] as num?)?.toDouble() ??
            0.0;
    double totalCarbs =
        (data["nutrition_info"][NutritionFields.totalCarbs] as num?)
                ?.toDouble() ??
            0.0;
    double totalFat = (data["nutrition_info"][NutritionFields.totalFat] as num?)
            ?.toDouble() ??
        0.0;
    double servingWeight =
        (data["nutrition_info"][MealFields.servingWeight] as num?)
                ?.toDouble() ??
            0.0;

    List<NutritionModel> nutrients = [
      NutritionModel(name: "Protein", amount: protein),
      NutritionModel(name: "Carbohydrate", amount: totalCarbs),
      NutritionModel(name: "Chất béo", amount: totalFat),
    ];

    List<String> warnings = data[MealFields.warnings]?.cast<String>() ?? [];

    String id = data["id"] ?? "";

    _navigateToMealScreen(
        context, id, foodName, servingWeight, calories, nutrients, [], warnings);
  }

  void _processGeminiModel(BuildContext context, Map<String, dynamic> data) {
    var totalNutrition = data["total_nutrition"]["total_nutrition"];
    double calories =
        (totalNutrition[MealFields.calories] as num?)?.toDouble() ?? 0.0;
    double protein =
        (totalNutrition[NutritionFields.protein] as num?)?.toDouble() ?? 0.0;
    double totalCarbs =
        (totalNutrition[NutritionFields.totalCarbs] as num?)?.toDouble() ?? 0.0;
    double totalFat =
        (totalNutrition[NutritionFields.totalFat] as num?)?.toDouble() ?? 0.0;

    var geminiResult = data["gemini_result"];
    var vietnameseNameMatch =
        RegExp(r'Vietnamese:\s*([^,]+)').firstMatch(geminiResult);
    String dishName = vietnameseNameMatch != null
        ? vietnameseNameMatch.group(1) ?? "Dish"
        : "Dish";

    var detailIngredients = data["total_nutrition"]["detailed_nutrition"];
    double totalWeight = detailIngredients.fold(0.0, (sum, ingredient) {
      String quantity = ingredient["quantity"];
      double weight = double.tryParse(quantity.split(" ")[0]) ?? 0.0;
      return sum + weight;
    });

    List<NutritionModel> nutrients = [
      NutritionModel(name: "Protein", amount: protein),
      NutritionModel(name: "Carbohydrate", amount: totalCarbs),
      NutritionModel(name: "Chất béo", amount: totalFat),
    ];

    List<IngredientModel> ingredientsList = _extractIngredients(data);

    List<String> warnings = data[MealFields.warnings]?.cast<String>() ?? [];

    String id = data["id"] ?? "";

    _navigateToMealScreen(
        context, id, dishName, totalWeight, calories, nutrients, ingredientsList, warnings);
  }

  List<IngredientModel> _extractIngredients(Map<String, dynamic> data) {
    var ingredients = data["ingredients"];
    var nameEnglish = ingredients
        .map((ingredient) => ingredient[IngredientFields.nameEnglish])
        .toList();
    var nameVietnamese = ingredients
        .map((ingredient) => ingredient[IngredientFields.nameVietnamese])
        .toList();

    var detailIngredients = data["total_nutrition"]["detailed_nutrition"];
    return detailIngredients.map<IngredientModel>((ingredient) {
      String name = ingredient["name"];
      String quantity = ingredient["quantity"];
      double calories =
          (ingredient[IngredientFields.calories] as num?)?.toDouble() ?? 0.0;
      return IngredientModel(
        nameEn: nameEnglish[nameEnglish.indexOf(name)],
        nameVi: nameVietnamese[nameEnglish.indexOf(name)],
        quantity: double.tryParse(quantity.split(" ")[0]) ?? 0.0,
        calories: calories,
      );
    }).toList();
  }

  void _navigateToMealScreen(
    BuildContext context,
    String id,
    String dishName,
    double servingWeight,
    double calories,
    List<NutritionModel> nutrients,
    List<IngredientModel> ingredients,
    List<String> warnings,
  ) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          meal: MealModel(
            id: "",
            name: dishName,
            weight: servingWeight,
            calories: calories,
            nutrients: nutrients,
            ingredients: ingredients,
            warnings: warnings,
            isFavorite: false,
            loggedAt: "",
            savedAt: "",
            type: "",
            userId: "",
            imageUrl: widget.image.path,
            serving: 1,
          ),
          imageUrl: widget.image.path,
        ),
      ),
      (route) =>
          route.isFirst, // Remove all previous routes, except Home Screen
    );
  }

  // Open the health info sheet
  void _showHealthInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nhập thông tin sức khỏe",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: "Đường huyết (mg/dL)",
                controller: _bloodSugarController,
                hint: "Ví dụ: 110",
                icon: Icons.water_drop,
                iconColor: AppColors.activeColor,
                isNumeric: true,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: "Huyết áp tâm thu (mmHg)",
                      controller: _systolicController,
                      hint: "Ví dụ: 120",
                      icon: Icons.favorite,
                      iconColor: AppColors.activeColor,
                      isNumeric: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInputField(
                      label: "Huyết áp tâm trương (mmHg)",
                      controller: _diastolicController,
                      hint: "Ví dụ: 80",
                      icon: Icons.favorite_border,
                      iconColor: AppColors.activeColor,
                      isNumeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      saveHealthData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Lưu thông tin",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      clearHealthData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Xoá dữ liệu",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void clearHealthData() {
    setState(() {
      _bloodSugarController.clear();
      _systolicController.clear();
      _diastolicController.clear();
      isHealthInfoEntered = false;
    });
    Navigator.pop(context);
  }

  void saveHealthData() {
    if (_bloodSugarController.text.isNotEmpty &&
        _systolicController.text.isNotEmpty &&
        _diastolicController.text.isNotEmpty) {
      setState(() {
        isHealthInfoEntered = true;
      });

      CustomSnackbar.show(context, "Thông tin sức khỏe đã được lưu!",
          isSuccess: true);
      Navigator.pop(context);
    } else {
      CustomSnackbar.show(context, "Vui lòng nhập đầy đủ thông tin sức khỏe!",
          isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: const CustomAppBar(title: "Xác nhận món ăn"),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        /// Image Preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.image,
                            width: double.infinity,
                            height: 500,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 30),

                        /// Input Field for Description
                        _buildInputField(
                          label: "Mô tả món ăn",
                          controller: _descriptionController,
                          hint: "Ví dụ: Hamburger phô mai với thịt bò và rau",
                          icon: Icons.description,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              /// Action Buttons (Sticks to Bottom)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // /// Health Info Button
                    // Expanded(
                    //   child: ElevatedButton.icon(
                    //     onPressed: () => _showHealthInfoSheet(context),
                    //     icon: Icon(
                    //       isHealthInfoEntered
                    //           ? Icons.check_circle
                    //           : Icons.health_and_safety,
                    //       color:
                    //           isHealthInfoEntered ? Colors.green : Colors.blue,
                    //     ),
                    //     label: Text(
                    //       isHealthInfoEntered
                    //           ? "Đã nhập chỉ số"
                    //           : "Nhập chỉ số",
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(vertical: 18),
                    //       backgroundColor: Colors.white,
                    //       foregroundColor: Colors.black,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //         side: const BorderSide(color: Colors.blue),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(width: 10),

                    /// Upload Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => uploadImage(),
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Xác nhận',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    Color? iconColor,
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          prefixIcon:
              icon != null ? Icon(icon, color: iconColor ?? Colors.grey) : null,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          hintMaxLines: 3,
        ),
      ),
    );
  }
}
