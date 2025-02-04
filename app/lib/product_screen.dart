import 'package:app/core/theme/app_colors.dart';
import 'package:app/home_meal.dart';
import 'package:app/models/meal_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductScreen extends StatefulWidget {
  final File image;

  ProductScreen({required this.image});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;
  // Function to upload the image and description to the server
  Future<void> uploadImage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    // For Mac
    final url = Uri.parse("http://172.16.1.205:5001/predict");
    // For Windows
    // final url = Uri.parse("http://10.0.2.2:5000/predict");

    // Create a multipart request with the image and description
    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', widget.image.path))
      ..fields['description'] =
          _descriptionController.text; // Add description as form field

    var response = await request.send();
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);

      print(data);

      if (data.containsKey("predictions_model")) {
        // Handle response from the AI model
        var predictions = data["predictions_model"];
        String foodName = predictions["name"];
        double calories =
            (predictions["nutrition_info"]["calories"] as num?)?.toDouble() ??
                0.0;
        double protein =
            (predictions["nutrition_info"]["protein"] as num?)?.toDouble() ??
                0.0;
        double totalCarbs =
            (predictions["nutrition_info"]["total_carbohydrate"] as num?)
                    ?.toDouble() ??
                0.0;
        double totalFat =
            (predictions["nutrition_info"]["total_fat"] as num?)?.toDouble() ??
                0.0;
        double servingWeight =
            (predictions["nutrition_info"]["serving_weight_grams"] as num?)
                    ?.toDouble() ??
                0.0;

        List<Nutrition> nutrients = [
          Nutrition(nutrientName: "Protein", nutrientValue: protein),
          Nutrition(nutrientName: "Total Carbohydrate", nutrientValue: totalCarbs),
          Nutrition(nutrientName: "Total Fat", nutrientValue: totalFat),
        ];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealHomeScreen(
              meal: Meal(
                name: foodName,
                weight: servingWeight,
                calories: calories,
                nutrients: nutrients,
                ingredients: [],
              ),
              imageUrl: widget.image.path,
            ),
          ),
        );
      } else if (data.containsKey("gemini_result")) {
        // Handle response from the Gemini model
        var totalNutrition = data["total_nutrition"]["total_nutrition"];
        double calories =
            (totalNutrition["calories"] as num?)?.toDouble() ?? 0.0;
        double protein = (totalNutrition["protein"] as num?)?.toDouble() ?? 0.0;
        double totalCarbs =
            (totalNutrition["total_carbohydrate"] as num?)?.toDouble() ?? 0.0;
        double totalFat =
            (totalNutrition["total_fat"] as num?)?.toDouble() ?? 0.0;

        var geminiResult = data["gemini_result"];
        var englishNameMatch =
            RegExp(r'English:\s*([^,]+)').firstMatch(geminiResult);
        String dishName = englishNameMatch != null
            ? englishNameMatch.group(1) ?? "Dish"
            : "Dish";

        List<Nutrition> nutrients = [
          // Nutrition(name: "Calories", amount: calories),
          Nutrition(nutrientName: "Protein", nutrientValue: protein),
          Nutrition(nutrientName: "Total Carbohydrate", nutrientValue: totalCarbs),
          Nutrition(nutrientName: "Total Fat", nutrientValue: totalFat),
        ];

        var ingredients = data["ingredients"];
        var nameEnglish = ingredients
            .map((ingredient) => ingredient["name_english"])
            .toList();
        var nameVietnamese = ingredients
            .map((ingredient) => ingredient["name_vietnamese"])
            .toList();

        var detailIngredients = data["total_nutrition"]["detailed_nutrition"];
        double totalWeight = detailIngredients.fold(0.0, (sum, ingredient) {
          String quantity = ingredient["quantity"];
          double weight = double.tryParse(quantity.split(" ")[0]) ?? 0.0;
          return sum + weight;
        });

        List<Ingredient> ingredientsList = [];

        ingredientsList.addAll(detailIngredients.map<Ingredient>((ingredient) {
          String name = ingredient["name"];
          String quantity = ingredient["quantity"];
          double ingredientCalories =
              (ingredient["calories"] as num?)?.toDouble() ?? 0.0;

          return Ingredient(
            nameEn: nameEnglish[nameEnglish.indexOf(name)],
            nameVi: nameVietnamese[nameEnglish.indexOf(name)],
            quantity: double.tryParse(quantity.split(" ")[0]) ?? 0.0,
            calories: ingredientCalories,
          );
        }).toList());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealHomeScreen(
              meal: Meal(
                name: dishName,
                weight: totalWeight,
                calories: calories,
                nutrients: nutrients,
                ingredients: ingredientsList,
              ),
              imageUrl: "", // Add image URL here if available
            ),
          ),
        );
      } else {
        print("Unknown response format.");
      }
    } else {
      print("Failed to upload image: ${response.statusCode}");
    }
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Image and description'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Confirm your photo?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      widget.image,
                      width: 600,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                    if (isLoading) CircularProgressIndicator(),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: Colors.grey[600]),
                  decoration: InputDecoration(
                    labelText: "Enter a description of the food",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[500]!,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send,
                          color: Colors.grey[600]), // Màu của icon nhạt hơn
                      onPressed: () => uploadImage(context),
                      tooltip: "Send",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}