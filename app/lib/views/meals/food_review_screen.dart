import 'dart:io';
import 'dart:convert';
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

  // Trạng thái dữ liệu đã nhập
  bool isHealthInfoEntered = false;

  Future<void> uploadImage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(ApiConstants.getPredictNutritionUrl());

    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', widget.image.path))
      ..fields['description'] = _descriptionController.text;

    // Thêm đường huyết vào yêu cầu nếu có
    if (_bloodSugarController.text.isNotEmpty) {
      request.fields['blood_sugar'] = _bloodSugarController.text;
    }

    // Thêm huyết áp vào yêu cầu nếu có
    if (_systolicController.text.isNotEmpty &&
        _diastolicController.text.isNotEmpty) {
      request.fields['blood_pressure'] = jsonEncode({
        "systolic": int.tryParse(_systolicController.text) ?? 0,
        "diastolic": int.tryParse(_diastolicController.text) ?? 0,
      });
    }

    var response = await request.send();
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      // print('Response: $data');

      if (data.containsKey("predictions_model")) {
        // var foodName = data["name"];
        double calories =
            (data["NutritionModel_info"]["calories"] as num?)?.toDouble() ??
                0.0;
        double protein =
            (data["NutritionModel_info"]["protein"] as num?)?.toDouble() ?? 0.0;
        double totalCarbs =
            (data["NutritionModel_info"]["total_carbohydrate"] as num?)
                    ?.toDouble() ??
                0.0;
        double totalFat =
            (data["NutritionModel_info"]["total_fat"] as num?)?.toDouble() ??
                0.0;
        double servingWeight =
            (data["NutritionModel_info"]["serving_weight_grams"] as num?)
                    ?.toDouble() ??
                0.0;

        List<NutritionModel> nutrients = [
          NutritionModel(name: "Protein", amount: protein),
          NutritionModel(name: "Total Carbohydrate", amount: totalCarbs),
          NutritionModel(name: "Total Fat", amount: totalFat),
        ];

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MealHomeScreen(
        //       meal: Meal(
        //         name: foodName,
        //         weight: servingWeight,
        //         calories: calories,
        //         nutrients: nutrients,
        //         IngredientModels: [],
        //         warnings: data['warnings'] ?? [],
        //       ),
        //       imageUrl: widget.image.path,
        //     ),
        //   ),
        // );
      } else if (data.containsKey("gemini_result")) {
        var totalNutritionModel =
            data["total_NutritionModel"]["total_NutritionModel"];
        double calories =
            (totalNutritionModel["calories"] as num?)?.toDouble() ?? 0.0;
        double protein =
            (totalNutritionModel["protein"] as num?)?.toDouble() ?? 0.0;
        double totalCarbs =
            (totalNutritionModel["total_carbohydrate"] as num?)?.toDouble() ??
                0.0;
        double totalFat =
            (totalNutritionModel["total_fat"] as num?)?.toDouble() ?? 0.0;

        var geminiResult = data["gemini_result"];
        var englishNameMatch =
            RegExp(r'English:\s*([^,]+)').firstMatch(geminiResult);
        String dishName = englishNameMatch != null
            ? englishNameMatch.group(1) ?? "Dish"
            : "Dish";

        List<NutritionModel> nutrients = [
          NutritionModel(name: "Protein", amount: protein),
          NutritionModel(name: "Total Carbohydrate", amount: totalCarbs),
          NutritionModel(name: "Total Fat", amount: totalFat),
        ];

        var IngredientModels = data["IngredientModels"];
        var nameEnglish = IngredientModels.map(
            (IngredientModel) => IngredientModel["name_english"]).toList();
        var nameVietnamese = IngredientModels.map(
            (IngredientModel) => IngredientModel["name_vietnamese"]).toList();

        var detailIngredientModels =
            data["total_NutritionModel"]["detailed_NutritionModel"];
        double totalWeight =
            detailIngredientModels.fold(0.0, (sum, IngredientModel) {
          String quantity = IngredientModel["quantity"];
          double weight = double.tryParse(quantity.split(" ")[0]) ?? 0.0;
          return sum + weight;
        });

        List<IngredientModel> IngredientModelsList = [];

        IngredientModelsList.addAll(
            detailIngredientModels.map<IngredientModel>((IngredientModel) {
          String name = IngredientModel["name"];
          String quantity = IngredientModel["quantity"];
          double IngredientModelCalories =
              (IngredientModel["calories"] as num?)?.toDouble() ?? 0.0;

          return IngredientModel(
            name_en: nameEnglish[nameEnglish.indexOf(name)],
            name_vi: nameVietnamese[nameEnglish.indexOf(name)],
            quantity: double.tryParse(quantity.split(" ")[0]) ?? 0.0,
            calories: IngredientModelCalories,
          );
        }).toList());

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MealHomeScreen(
        //       meal: Meal(
        //         name: dishName,
        //         weight: totalWeight,
        //         calories: calories,
        //         nutrients: nutrients,
        //         IngredientModels: IngredientModelsList,
        //         warnings: data['warnings'] ?? [],
        //       ),
        //       imageUrl: widget.image.path,
        //     ),
        //   ),
        // );
      } else {
        CustomSnackbar.show(context, "Không thể xác định món ăn!",
            isSuccess: false);
      }
    } else {
      print("Failed to upload image: ${response.statusCode}");
      CustomSnackbar.show(context, "Lỗi: ${response.reasonPhrase}",
          isSuccess: false);
    }
    setState(() {
      isLoading = false;
    });
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
                      setState(() {
                        isHealthInfoEntered = true;
                      });
                      Navigator.pop(context);
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
                      setState(() {
                        // Clear all input fields
                        _bloodSugarController.clear();
                        _systolicController.clear();
                        _diastolicController.clear();
                        isHealthInfoEntered = false;
                      });
                      Navigator.pop(context);
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
                    /// Health Info Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showHealthInfoSheet(context),
                        icon: Icon(
                          isHealthInfoEntered
                              ? Icons.check_circle
                              : Icons.health_and_safety,
                          color:
                              isHealthInfoEntered ? Colors.green : Colors.blue,
                        ),
                        label: Text(
                          isHealthInfoEntered
                              ? "Đã nhập chỉ số"
                              : "Nhập chỉ số",
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    /// Upload Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          uploadImage(context);
                        },
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
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
