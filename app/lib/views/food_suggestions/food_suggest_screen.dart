import 'package:app/core/network/api_constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/views/food_suggestions/food_info_screen.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodSuggestScreen extends StatefulWidget {
  const FoodSuggestScreen({super.key});

  @override
  State<FoodSuggestScreen> createState() => _FoodSuggestScreenState();
}

class _FoodSuggestScreenState extends State<FoodSuggestScreen>
    with SingleTickerProviderStateMixin {
  final cuisineMap = {
    "Bất kỳ": "",
    "Việt Nam": "Vietnamese",
    "Ý": "Italian",
    "Mexico": "Mexican",
    "Mỹ": "American",
    "Ấn Độ": "Indian",
    "Nhật Bản": "Japanese",
    "Hàn Quốc": "Korean",
    "Thái Lan": "Thai",
    "Châu Phi": "African",
    "Châu Á": "Asian",
    "Anh Quốc": "British",
    "Caribbean": "Caribbean",
    "Trung Quốc": "Chinese",
    "Đông Âu": "Eastern European",
    "Châu Âu": "European",
    "Pháp": "French",
    "Đức": "German",
    "Hy Lạp": "Greek",
    "Ireland": "Irish",
    "Do Thái": "Jewish",
    "Châu Mỹ Latinh": "Latin American",
    "Địa Trung Hải": "Mediterranean",
    "Trung Đông": "Middle Eastern",
    "Bắc Âu": "Nordic",
    "Tây Ban Nha": "Spanish"
  };

  String selectedCuisine = "Việt Nam";
  String userGoal = "Duy trì cân nặng";

  double tdeeCalories = 0;
  late TextEditingController _calorieController;

  bool isLoading = false;
  List<Map<String, dynamic>> recipes = [];

  Map<String, double> recommendedNutrition = {};

  late TabController _tabController;
  List<Map<String, dynamic>> savedRecipes = [];

  // Map ánh xạ từ tiếng Việt sang tiếng Anh để gửi API
  final Map<String, String> ingredientMap = {
    "Đường": "sugar",
    "Đường mía": "cane sugar",
    "Mật ong": "honey",
    "Muối biển": "sea salt",
    "Muối ăn": "salt",
    "Nước tương": "soy sauce",
    "Nước mắm": "fish sauce",
    "Giấm": "vinegar",
    "Chanh vàng": "lemon",
    "Chanh xanh": "lime",
    "Sô cô la đen": "dark chocolate",
    "Cà phê": "coffee",
    "Vị umami": "umami",
    "Cá cơm": "anchovies",
    "Bơ": "butter",
    "Dầu ô liu": "olive oil",
    "Kem tươi": "cream",
    "Dầu dừa": "coconut oil",
    "Chanh": "lemon",
  };

  Map<String, bool> selectedIngredientsMap = {
    "Đường": false,
    "Đường mía": false,
    "Mật ong": false,
    "Muối biển": false,
    "Muối ăn": false,
    "Nước tương": false,
    "Nước mắm": false,
    "Giấm": false,
    "Chanh vàng": false,
    "Chanh xanh": false,
    "Chanh": false,
    "Sô cô la đen": false,
    "Cà phê": false,
    "Vị umami": false,
    "Cá cơm": false,
    "Bơ": false,
    "Dầu ô liu": false,
    "Kem tươi": false,
    "Dầu dừa": false,
  };

  // Danh sách các thành phần đã chọn
  List<String> selectedIngredients = [];

  Future<void> fetchSavedRecipes() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Người dùng chưa đăng nhập!");
      }

      String userId = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('saved_recipes')
          .doc(userId)
          .collection('recipes')
          .get();

      setState(() {
        savedRecipes = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        'Lỗi khi tải danh sách món ăn đã lưu: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> fetchRecipes() async {
    validateAndFetchRecipes();

    final String backendUrl = ApiConstants.getSuggestRecipesUrl();

    final List<String> selectedIngredients = selectedIngredientsMap.entries
        .where((entry) => entry.value)
        .map((entry) => ingredientMap[entry.key]!) // Lấy tên tiếng Anh
        .toList();

    final Map<String, dynamic> requestBody = {
      "userId": FirebaseAuth.instance.currentUser?.uid ?? "unknown",
      "preferences": {
        "cuisine": cuisineMap[selectedCuisine],
        "ingredients": selectedIngredients,
      },
      "nutrition": {
        "calories_min": recommendedNutrition["Calories_Min"]!.toInt(),
        "calories_max": recommendedNutrition["Calories_Max"]!.toInt(),
        "protein_min": recommendedNutrition["Protein_Min"]!.toInt(),
        "protein_max": recommendedNutrition["Protein_Max"]!.toInt(),
        "fat_min": recommendedNutrition["Fat_Min"]!.toInt(),
        "fat_max": recommendedNutrition["Fat_Max"]!.toInt(),
        "carbs_min": recommendedNutrition["Carbs_Min"]!.toInt(),
        "carbs_max": recommendedNutrition["Carbs_Max"]!.toInt(),
      },
    };

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          recipes = List<Map<String, dynamic>>.from(data['recipes']);
        });
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Không tìm thấy món ăn'),
                content: const Text(
                  'Rất tiếc, không tìm thấy món ăn phù hợp với tiêu chí bạn đã chọn. Vui lòng thử lại với các tùy chọn khác.',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Đóng'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        'Lỗi khi tìm món ăn: $e',
        isSuccess: false,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteSavedRecipe(int recipeId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Người dùng chưa đăng nhập!");
      }

      String userId = user.uid;

      await FirebaseFirestore.instance
          .collection('saved_recipes')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId.toString())
          .delete();

      // Cập nhật danh sách
      setState(() {
        savedRecipes.removeWhere((recipe) => recipe['id'] == recipeId);
      });

      CustomSnackbar.show(
        context,
        'Món ăn đã được xóa!',
        isSuccess: true,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        'Lỗi khi xóa: $e',
        isSuccess: false,
      );
    }
  }

  void _calculateRecommendedNutrition() {
    final goalAdjustment = {
      "Duy trì cân nặng": 1.0,
      "Tăng cân": 1.3,
      "Giảm cân": 0.9,
    };

    final factor = goalAdjustment[userGoal]!;

    double proteinRatio = 0.15;
    double fatRatio = 0.25;
    double carbsRatio = 0.60;

    // Tính chỉ số dinh dưỡng cơ bản
    final protein = tdeeCalories * factor * proteinRatio / 4;
    final fat = tdeeCalories * factor * fatRatio / 9;
    final carbs = tdeeCalories * factor * carbsRatio / 4;

    // Thêm biên độ dao động (flexibility)
    const proteinFlexibility = 0.20; // ±20%
    const fatFlexibility = 0.15; // ±15%
    const carbsFlexibility = 0.15; // ±15%
    const calorieFlexibility = 0.10; // ±10%

    recommendedNutrition = {
      "Protein_Min": protein * (1 - proteinFlexibility),
      "Protein_Max": protein * (1 + proteinFlexibility),
      "Fat_Min": fat * (1 - fatFlexibility),
      "Fat_Max": fat * (1 + fatFlexibility),
      "Carbs_Min": carbs * (1 - carbsFlexibility),
      "Carbs_Max": carbs * (1 + carbsFlexibility),
      "Calories_Min": tdeeCalories * (1 - calorieFlexibility),
      "Calories_Max": tdeeCalories * (1 + calorieFlexibility),
    };

    setState(() {});
  }

  // Hàm lấy danh sách thành phần tiếng Anh để gửi API
  List<String> getSelectedIngredientsForAPI() {
    return selectedIngredients.map((vi) => ingredientMap[vi]!).toList();
  }

  Future<void> fetchUserGoal() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userGoal =
            userDoc.data()?['goal'] ?? 'Duy trì cân nặng'; // Giá trị mặc định
      });

      _calculateRecommendedNutrition();
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, 'Lỗi khi lấy mục tiêu: $e',
          isSuccess: false);
    }
  }

  Future<void> fetchCalories() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        tdeeCalories = (userDoc.data()?['calories'] ?? 2000).toDouble();
        _calorieController.text = tdeeCalories.toStringAsFixed(0);
      });
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, 'Lỗi khi lấy calories: $e',
          isSuccess: false);
    }
  }

  void validateAndFetchRecipes() {
    if (_calorieController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        'Vui lòng nhập lượng calories trước khi tìm kiếm!',
        isSuccess: false,
      );
      return;
    }
  }

  @override
  initState() {
    super.initState();
    _calorieController = TextEditingController(text: 1000.toStringAsFixed(0));
    _calculateRecommendedNutrition();
    _tabController = TabController(length: 2, vsync: this);
    tdeeCalories = 2000;
    fetchSavedRecipes();
    fetchCalories();
    fetchUserGoal();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  Widget _buildCuisineDropdown() {
    return _buildCard(
      title: "Chọn quốc gia:",
      child: DropdownButtonFormField<String>(
        value: selectedCuisine,
        decoration: InputDecoration(
          labelText: "Quốc gia",
          prefixIcon: const Icon(Icons.flag, color: Colors.deepPurpleAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        items: cuisineMap.keys.map((cuisine) {
          return DropdownMenuItem(
            value: cuisine,
            child: Row(
              children: [
                const Icon(Icons.flag, color: Colors.orangeAccent),
                const SizedBox(width: 10),
                Text(
                  cuisine,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCuisine = value!;
          });
        },
      ),
    );
  }

  Widget _buildGoalDropdown() {
    return _buildCard(
      title: "Chọn mục tiêu:",
      child: DropdownButtonFormField<String>(
        value: userGoal,
        decoration: InputDecoration(
          labelText: "Mục tiêu",
          prefixIcon: const Icon(Icons.stars, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        items: [
          "Duy trì cân nặng",
          "Tăng cân",
          "Giảm cân",
        ]
            .map((goal) => DropdownMenuItem(
                  value: goal,
                  child: Text(
                    goal,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            userGoal = value!;
            _calculateRecommendedNutrition();
          });
        },
      ),
    );
  }

  Widget _buildIngredientSelection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: ingredientMap.keys.map((ingredientVi) {
          bool isSelected = selectedIngredients.contains(ingredientVi);
          return ChoiceChip(
            label: Text(ingredientVi),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  selectedIngredients.add(ingredientVi);
                } else {
                  selectedIngredients.remove(ingredientVi);
                }
              });
            },
            selectedColor: Colors.green,
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCaloriesInput() {
    return _buildCard(
      title: "Lượng calories:",
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              controller: _calorieController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(5), // Giới hạn tối đa 5 chữ số
                FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
              ],
              decoration: InputDecoration(
                labelText: "Nhập calories",
                labelStyle: const TextStyle(color: Colors.teal),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.teal),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              await fetchCalories(); // Lấy calories từ Firestore
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 34, 0, 255),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Mặc định",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    // Tab Đề xuất món ăn
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContainer(children: [
              _buildCuisineDropdown(),
              _buildGoalDropdown(),
              _buildCaloriesInput(),
              // Divider(
              //   color: Colors.grey[400],
              //   thickness: 0.7,
              //   height: 20,
              // ),
              // _buildIngredientSelection(),
            ]),
            const SizedBox(height: 14),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  fetchRecipes();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Tìm món ăn phù hợp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recipes.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Kết quả trả về:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              ...recipes.map((recipe) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  color: Colors.white,
                  child: ListTile(
                    leading: recipe['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(recipe['image'],
                                width: 60, height: 60, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.fastfood, color: Colors.deepPurple),
                    title: Text(
                      recipe['title_translated'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    subtitle: (recipe['nutrition'] != null &&
                            recipe['nutrition']['nutrients'] != null)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(
                                  recipe['nutrition']['nutrients'].length,
                                  (index) {
                                final nutrient =
                                    recipe['nutrition']['nutrients'][index];
                                return Text(
                                  '${nutrient['name']}: ${nutrient['amount']} ${nutrient['unit']}',
                                  style: const TextStyle(fontSize: 16),
                                );
                              }),
                            ],
                          )
                        : const Text('Không có thông tin dinh dưỡng.'),
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodInfoScreen(recipe: recipe),
                        ),
                      ),
                    },
                  ),
                );
              }).toList()
            ] else
              const Center(
                child: Text(
                  'Không tìm thấy món ăn phù hợp.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedRecipesTab() {
    fetchSavedRecipes();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: savedRecipes.isEmpty
            ? const Center(
                child: Text(
                  'Không có món ăn nào được lưu.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'Danh sách món ăn đã lưu:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  ...savedRecipes.map((recipe) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      color: Colors.white,
                      child: ListTile(
                        leading: recipe['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  recipe['image'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood,
                                color: Colors.deepPurple),
                        title: Text(
                          recipe['title_translated'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        subtitle: (recipe['nutrition'] != null &&
                                recipe['nutrition']['nutrients'] != null)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...List.generate(
                                    recipe['nutrition']['nutrients'].length,
                                    (index) {
                                      final nutrient = recipe['nutrition']
                                          ['nutrients'][index];
                                      return Text(
                                        '${nutrient['name']}: ${nutrient['amount']} ${nutrient['unit']}',
                                        style: const TextStyle(fontSize: 14),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : const Text(
                                'Không có thông tin dinh dưỡng.',
                                style: TextStyle(fontSize: 14),
                              ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoodInfoScreen(recipe: recipe),
                            ),
                          ),
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteSavedRecipe(recipe['id']);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 90),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Món ăn'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Đề xuất món ăn'),
            Tab(text: 'Món đã lưu'),
          ],
          labelColor: Colors.white, // Màu chữ khi được chọn
          unselectedLabelColor: Colors.black54, // Màu chữ khi không được chọn
          labelStyle: const TextStyle(
            fontSize: 18, // Tăng kích thước chữ
            fontWeight: FontWeight.bold, // Làm đậm chữ
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16, // Kích thước chữ nhỏ hơn khi không được chọn
          ),
          indicatorColor: Colors.white, // Màu của đường chỉ dưới tab
          indicatorWeight: 3.0, // Độ dày của đường chỉ
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSuggestionsTab(),
          _buildSavedRecipesTab(),
        ],
      ),
    );
  }
}
