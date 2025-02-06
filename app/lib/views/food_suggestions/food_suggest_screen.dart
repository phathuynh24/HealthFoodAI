import 'package:app/core/network/api_constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/views/food_suggestions/food_info_screen.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodSuggestScreen extends StatefulWidget {
  final double defaultCalories;
  const FoodSuggestScreen({super.key, required this.defaultCalories});

  @override
  State<FoodSuggestScreen> createState() =>
      _FoodSuggestScreenState();
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
  String userGoal = "Giữ cân";

  bool isSweet = false;
  bool isSalty = false;
  bool isSour = false;
  bool isBitter = false;
  bool isSavory = false;
  bool isFatty = false;

  double tdeeCalories = 0;
  double inputCalories = 800;

  bool isLoading = false;
  List<Map<String, dynamic>> recipes = [];

  Map<String, double> recommendedNutrition = {};

  late TabController _tabController;
  List<Map<String, dynamic>> savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _calculateRecommendedNutrition();
    _tabController = TabController(length: 2, vsync: this);
    tdeeCalories = widget.defaultCalories;
    fetchSavedRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        savedRecipes = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      CustomSnackbar.show(
       context,
      'Lỗi khi tải danh sách món ăn đã lưu: $e',
       isSuccess: false,
      );
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
      "Giữ cân": 1.0,
      "Tăng cân": 1.1,
      "Giảm cân": 0.9,
      "Tập gym": 1.2,
      "Suy dinh dưỡng": 1.3,
      "Béo phì": 0.8,
      "Bệnh tim mạch": 1.0,
    };

    final factor = goalAdjustment[userGoal]!;

    double proteinRatio = 0.15;
    double fatRatio = 0.25;
    double carbsRatio = 0.60;

    if (userGoal == "Tập gym") {
      proteinRatio = 0.25;
      fatRatio = 0.20;
      carbsRatio = 0.55;
    } else if (userGoal == "Bệnh tim mạch") {
      proteinRatio = 0.20;
      fatRatio = 0.15;
      carbsRatio = 0.65;
    } else if (userGoal == "Béo phì") {
      proteinRatio = 0.20;
      fatRatio = 0.20;
      carbsRatio = 0.60;
    }

    final protein = tdeeCalories * factor * proteinRatio / 4;
    final fat = tdeeCalories * factor * fatRatio / 9;
    final carbs = tdeeCalories * factor * carbsRatio / 4;

    recommendedNutrition = {
      "Protein": protein,
      "Fat": fat,
      "Carbs": carbs,
    };

    setState(() {});
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          "Giữ cân",
          "Tăng cân",
          "Giảm cân",
          // "Tập gym",
          // "Suy dinh dưỡng",
          // "Béo phì",
          // "Bệnh tim mạch",
        ]
            .map((goal) => DropdownMenuItem(
                  value: goal,
                  child: Text(
                    goal,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildTasteSelection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildTasteChip('Ngọt', isSweet, (value) {
            setState(() {
              isSweet = value;
            });
          }),
          _buildTasteChip('Mặn', isSalty, (value) {
            setState(() {
              isSalty = value;
            });
          }),
          _buildTasteChip('Chua', isSour, (value) {
            setState(() {
              isSour = value;
            });
          }),
          _buildTasteChip('Đắng', isBitter, (value) {
            setState(() {
              isBitter = value;
            });
          }),
          _buildTasteChip('Đậm đà', isSavory, (value) {
            setState(() {
              isSavory = value;
            });
          }),
          _buildTasteChip('Béo', isFatty, (value) {
            setState(() {
              isFatty = value;
            });
          }),
        ],
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
              onChanged: (value) {
                setState(() {
                  inputCalories = double.tryParse(value) ?? 800;
                });
              },
              controller:
                  TextEditingController(text: inputCalories.toStringAsFixed(0)),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                inputCalories = tdeeCalories;
              });
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

  Widget _buildTasteChip(
      String label, bool selected, Function(bool) onChanged) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      selectedColor: Colors.pinkAccent,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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

  Future<void> fetchRecipes() async {
    final String backendUrl = ApiConstants.getSuggestRecipesUrl();

    final Map<String, dynamic> requestBody = {
      "userId": "12345",
      "preferences": {
        "cuisine": cuisineMap[selectedCuisine],
        "sweet": isSweet,
        "salty": isSalty,
        "sour": isSour,
        "bitter": isBitter,
        "savory": isSavory,
        "fatty": isFatty,
      },
      "nutrition": {
        "calories": inputCalories.toInt(),
        "protein": recommendedNutrition["Protein"]!.toInt(),
        "fat": recommendedNutrition["Fat"]!.toInt(),
        "carbs": recommendedNutrition["Carbs"]!.toInt(),
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
    } catch (e) {
      print('Lỗi trong quá trình gọi API: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              Divider(
                color: Colors.grey[400],
                thickness: 0.7,
                height: 20,
              ),
              _buildTasteSelection(),
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
                          recipe['title_translated'] ??
                              'N/A',
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
                              builder: (context) => FoodInfoScreen(recipe: recipe),
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
          unselectedLabelColor: Colors.grey[300], // Màu chữ khi không được chọn
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
