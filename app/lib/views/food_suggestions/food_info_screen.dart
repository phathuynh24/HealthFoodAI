import 'package:app/core/theme/app_theme.dart';
import 'package:app/models/diet_model.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FoodInfoScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const FoodInfoScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<FoodInfoScreen> createState() => _FoodInfoScreenState();
}

class _FoodInfoScreenState extends State<FoodInfoScreen> {
  bool isSave = false;

  void saveRecipe(Map<String, dynamic> recipe) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Người dùng chưa đăng nhập!");
      }

      String userId = user.uid;
      String docId = recipe['id'].toString();

      // Lưu món ăn vào Firestore
      await FirebaseFirestore.instance
          .collection('saved_recipes')
          .doc(userId) // Mỗi người dùng có một tài liệu
          .collection('recipes') // Lưu trong collection con
          .doc(docId)
          .set(recipe);

      CustomSnackbar.show(context, 'Món ăn đã được lưu vào danh sách!',
          isSuccess: true);
    } catch (e) {
      CustomSnackbar.show(context, 'Lỗi khi lưu món ăn: $e', isSuccess: false);
    }
  }

  void unsaveRecipe(Map<String, dynamic> recipe) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Người dùng chưa đăng nhập!");
      }

      String userId = user.uid;
      String docId =
          recipe['id'].toString(); // Sử dụng ID món ăn làm ID tài liệu

      // Xóa món ăn khỏi Firestore
      await FirebaseFirestore.instance
          .collection('saved_recipes')
          .doc(userId)
          .collection('recipes')
          .doc(docId)
          .delete();

      CustomSnackbar.show(context, 'Món ăn đã được xóa khỏi danh sách!',
          isSuccess: true);
    } catch (e) {
      CustomSnackbar.show(context, 'Lỗi khi xóa món ăn: $e', isSuccess: false);
    }
  }

  void checkIfSaved() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isSave = false);
        return;
      }

      String userId = user.uid;
      String docId =
          widget.recipe['id'].toString(); // Sử dụng ID món ăn làm ID tài liệu

      // Kiểm tra món ăn đã được lưu chưa
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('saved_recipes')
          .doc(userId)
          .collection('recipes')
          .doc(docId)
          .get();

      setState(() {
        isSave = doc.exists; // Nếu tài liệu tồn tại, set isSave = true
      });
    } catch (e) {
      CustomSnackbar.show(context, 'Lỗi khi kiểm tra món ăn đã lưu: $e',
          isSuccess: false);
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfSaved();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title_translated'] ?? 'Chi tiết món ăn'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSave ? Icons.bookmark_added : Icons.bookmark_add_outlined,
              color: isSave ? Colors.yellow : Colors.white,
            ),
            tooltip: isSave ? 'Đã lưu món ăn' : 'Lưu món ăn',
            iconSize: 35,
            onPressed: () {
              setState(() {
                isSave = !isSave;
                if (isSave) {
                  saveRecipe(recipe); // Lưu món ăn
                } else {
                  unsaveRecipe(recipe); // Xóa món ăn
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe['image'] != null)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4), // Hiệu ứng bóng đổ
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      recipe['image'],
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    recipe['title_translated'] ?? 'Không có tiêu đề',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // color: Colors.teal,
                    ),
                    textAlign: TextAlign.left,
                    softWrap: true, // Tự động xuống dòng khi hết chiều rộng
                    overflow:
                        TextOverflow.ellipsis, // Hiển thị dấu "..." nếu quá dài
                    maxLines: 3, // Giới hạn số dòng
                  ),
                ),
              ],
            ),
            // Thông tin chi tiết món ăn
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Id món ăn: ${recipe['id'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Thời gian chuẩn bị: ${recipe['readyInMinutes'] ?? 'N/A'} phút',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Khẩu phần: ${recipe['servings'] ?? 'N/A'} khẩu phần',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Lượt thích: ${recipe['aggregateLikes'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.health_and_safety, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Điểm sức khỏe: ${recipe['healthScore'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (recipe['diets'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chế độ ăn phù hợp:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(
                      height: 8), // Khoảng cách nhỏ giữa tiêu đề và chip
                  Wrap(
                    spacing: 8.0, // Khoảng cách ngang giữa các chip
                    runSpacing: 4.0, // Khoảng cách dọc giữa các dòng chip
                    children: recipe['diets'].map<Widget>((dietName) {
                      // Tìm chế độ ăn từ danh sách Diet.getAllDiets()
                      final diet = DietModel.getAllDiets().firstWhere(
                        (d) => d.name.toString().toLowerCase() == dietName,
                        orElse: () => DietModel(
                            name: dietName,
                            description: "Không có mô tả chi tiết."),
                      );

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                title: Text(
                                  diet.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                content: Text(
                                  diet.description,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Đóng',
                                      style: TextStyle(color: Colors.teal),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Chip(
                          label: Text(
                            diet.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.teal, // Màu nền chip
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            const SizedBox(height: 16),
            // Nguyên liệu
            if (recipe['extendedIngredients'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nguyên liệu:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(recipe['extendedIngredients'].length,
                      (index) {
                    final ingredient = recipe['extendedIngredients'][index];
                    return Container(
                      // margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      // decoration: BoxDecoration(
                      //   color: Colors.teal.withOpacity(0.1),
                      //   borderRadius: BorderRadius.circular(8.0),
                      // ),
                      child: Row(
                        children: [
                          if (ingredient['image'] != null)
                            Image.network(
                              'https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Trả về Icon nếu ảnh lỗi
                                return const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                );
                              },
                            )
                          else
                            const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ingredient['translated_original'] ?? 'N/A',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            const SizedBox(height: 16),
            // Các bước
            const Text(
              'Các bước thực hiện:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(recipe['introduce'].length, (index) {
              final steps = recipe['introduce'][index]['steps'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map<Widget>((step) {
                  if (step['translated_step'] == '') return const SizedBox();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    // decoration: BoxDecoration(
                    //   color: Colors.orangeAccent.withOpacity(0.1),
                    //   borderRadius: BorderRadius.circular(8.0),
                    // ),
                    child: Text(
                      '- ${step['translated_step']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),
            if (recipe['nutrition'] != null &&
                recipe['nutrition']['nutrients'] != null)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade100, Colors.teal.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin dinh dưỡng:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(recipe['nutrition']['nutrients'].length,
                        (index) {
                      final nutrient = recipe['nutrition']['nutrients'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.food_bank_outlined,
                              color: Colors.teal.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${nutrient['name']}: ${nutrient['amount']} ${nutrient['unit']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
