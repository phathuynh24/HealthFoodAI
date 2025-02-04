// import 'package:app/widgets/separator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   DateTime selectedDate = DateTime.now();
//   var remainingCalories;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             (selectedDate.year == DateTime.now().year &&
//                     selectedDate.month == DateTime.now().month &&
//                     selectedDate.day == DateTime.now().day)
//                 ? "Hôm nay"
//                 : DateFormat('dd-MM-yyyy').format(selectedDate),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             setState(() {
//               selectedDate = selectedDate.subtract(const Duration(days: 1));
//             });
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.arrow_forward, color: Colors.white),
//             onPressed: () {
//               setState(() {
//                 selectedDate = selectedDate.add(const Duration(days: 1));
//               });
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Navigator.of(context).push(
//           //   MaterialPageRoute(
//           //     builder: (context) => const ProductScanScreen(),
//           //   ),
//           // );
//         },
//         backgroundColor: Colors.blueAccent.shade400,
//         child: Container(
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.deepPurple.withOpacity(0.4),
//                 spreadRadius: 1,
//                 blurRadius: 10,
//               ),
//             ],
//           ),
//           child: Image.asset(
//             'assets/camera.png',
//             width: 50,
//             height: 50,
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('logged_meals')
//             .where('loggedAt',
//                 isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
//             .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data?.docs ?? [];
//           final totalCalories = docs.fold<int>(
//             0,
//             (sum, doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               final calories = (data['calories'] ?? 0) as num;
//               return sum + calories.toInt();
//             },
//           );

//           return Container(
//             color: const Color.fromARGB(255, 225, 236, 249),
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 _buildCalorieSummary(totalCalories),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       FutureBuilder<DocumentSnapshot>(
//                         future: FirebaseFirestore.instance
//                             .collection('user_goal_plans')
//                             .doc(FirebaseAuth.instance.currentUser!.uid)
//                             .get(),
//                         builder: (context, snapshot) {
//                           // Check if the snapshot has data and is not loading
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                                 child:
//                                     CircularProgressIndicator()); // Show a loading indicator while waiting
//                           }

//                           if (snapshot.hasError) {
//                             return Center(
//                                 child: Text(
//                                     'Error: ${snapshot.error}')); // Show error if any
//                           }

//                           if (!snapshot.hasData || snapshot.data == null) {
//                             return GestureDetector(
//                               onTap: () {
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(
//                                 //       builder: (context) =>
//                                 //           const GenderSelectionScreen()),
//                                 // );
//                               },
//                               child: Card(
//                                 margin: const EdgeInsets.symmetric(
//                                     vertical: 10, horizontal: 15),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       15), // Mềm mại các góc
//                                 ),
//                                 elevation: 5, // Độ bóng nhẹ
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     gradient: const LinearGradient(
//                                       colors: [
//                                         Colors.blueAccent,
//                                         Colors.greenAccent
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                     ),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   padding: const EdgeInsets.all(15.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Vui lòng nhấn vào để nhập thông tin',
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .titleLarge
//                                             ?.copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors
//                                                   .white, // Màu chữ sáng trên nền gradient
//                                             ),
//                                       ),
//                                       const SizedBox(height: 10),
//                                       const Text(
//                                         'Chưa có thông tin về chiều cao, cân nặng và giới tính.',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: Colors
//                                               .white70, // Màu chữ nhẹ nhàng, dễ nhìn
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }

//                           // When data is available, parse the snapshot
//                           final userDoc =
//                               snapshot.data!.data() as Map<String, dynamic>;
//                           final height = userDoc['height'] ?? '0';
//                           final weight = userDoc['weight'] ?? '0';
//                           final gender = userDoc['gender'] ?? '';

//                           bool _isExpanded = false; // Trạng thái mở/thu gọn

//                           return GestureDetector(
//                             onTap: () {
//                               // Navigator.push(
//                               //   context,
//                               //   MaterialPageRoute(
//                               //       builder: (context) =>
//                               //           const GenderSelectionScreen()),
//                               // );
//                             },
//                             child: StatefulBuilder(
//                               builder: (context, setState) {
//                                 return Card(
//                                   margin: const EdgeInsets.symmetric(
//                                       vertical: 10, horizontal: 15),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         12), // Mềm mại các góc
//                                   ),
//                                   elevation:
//                                       8, // Độ bóng đổ mạnh hơn để tạo sự nổi bật
//                                   color: Colors.blueAccent.shade100,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(15.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () {
//                                             setState(() {
//                                               _isExpanded = !_isExpanded;
//                                             });
//                                           },
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 'Thông tin cá nhân',
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .titleLarge
//                                                     ?.copyWith(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.white,
//                                                       fontSize: 18,
//                                                     ),
//                                               ),
//                                               Icon(
//                                                 _isExpanded
//                                                     ? Icons.keyboard_arrow_up
//                                                     : Icons.keyboard_arrow_down,
//                                                 color: Colors.white,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(height: 12),
//                                         if (_isExpanded) ...[
//                                           _buildInfoText(
//                                               'Chiều cao: ', '$height'),
//                                           _buildInfoText(
//                                               'Cân nặng: ', '$weight'),
//                                           _buildInfoText('Giới tính: ', gender),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                       _buildMealEntry(),
//                       _buildMealTypeSection(
//                           'Buổi sáng', Icons.breakfast_dining),
//                       _buildMealTypeSection('Buổi trưa', Icons.lunch_dining),
//                       _buildMealTypeSection('Buổi tối', Icons.dinner_dining),
//                       _buildMealTypeSection('Ăn vặt', Icons.fastfood),
//                       // const Divider(),
//                       // _buildExerciseEntry(
//                       //     "Exercise", Icons.directions_run, "0 Cal"),
//                       // _buildExerciseEntry(
//                       //     "Daily steps", Icons.directions_walk, "5000 steps"),
//                       // WaterTrackerWidget()
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoText(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.white70, // Màu sắc nhẹ nhàng, dễ nhìn
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             value.isEmpty ? 'Chưa có' : value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white, // Màu sắc nổi bật cho giá trị
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCalorieSummary(int totalCalories) {
//     return StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('logged_meals')
//             .where('loggedAt',
//                 isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
//             .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data?.docs ?? [];
//           // double totalCalories = 0;
//           double totalCarbs = 0;
//           double totalProtein = 0;
//           double totalFat = 0;

//           for (var doc in docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             final nutrients = data['nutrients'] as List<dynamic>? ?? [];

//             for (var nutrient in nutrients) {
//               final nutrientData = nutrient as Map<String, dynamic>;
//               final name = nutrientData['name'];
//               final amount = nutrientData['amount'] ?? 0;

//               if (name == "Total Carbohydrate") {
//                 totalCarbs += amount;
//               } else if (name == "Protein") {
//                 totalProtein += amount;
//               } else if (name == "Total Fat") {
//                 totalFat += amount;
//               }
//             }
//           }
//           totalCarbs = double.parse(totalCarbs.toStringAsFixed(1));
//           totalProtein = double.parse(totalProtein.toStringAsFixed(1));
//           totalFat = double.parse(totalFat.toStringAsFixed(1));

//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16)),
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Calories",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const Text("Remaining = Goal - Food + Exercise"),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Hiển thị hình tròn Calorie
//                         _buildCircularCalorieDisplay(totalCalories),
//                         // Thông tin chi tiết Calorie
//                         _buildCalorieDetails(),
//                       ],
//                     ),
//                     SizedBox(
//                         height: 40,
//                         child: Separator(color: Colors.grey.shade400)),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         _buildNutrientInfo("Carbs", "$totalCarbs"),
//                         _buildNutrientInfo("Protein", "$totalProtein"),
//                         _buildNutrientInfo("Fat", "$totalFat"),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//   }

//   Widget _buildCircularCalorieDisplay(int totalCalories) {
//     return Column(
//       children: [
//         SizedBox(
//           width: 100,
//           height: 100,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               CircularProgressIndicator(
//                 value: totalCalories / 2502,
//                 strokeWidth: 8,
//                 color: Colors.green,
//                 backgroundColor: Colors.grey.shade300,
//               ),
//               Center(
//                 child: FutureBuilder<DocumentSnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('user_goal_plans')
//                       .doc(FirebaseAuth.instance.currentUser!.uid)
//                       .get(),
//                   builder: (context, goalSnapshot) {
//                     if (goalSnapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     }
//                     if (!goalSnapshot.hasData || goalSnapshot.data == null) {
//                       return const Text("No goal data available");
//                     }
//                     final goalData =
//                         goalSnapshot.data!.data() as Map<String, dynamic>;
//                     final goal = (goalData['adjustedCalories'] ?? 0) as num;

//                     return StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection('logged_meals')
//                           .where('loggedAt',
//                               isEqualTo:
//                                   DateFormat('yyyy-MM-dd').format(selectedDate))
//                           .where('userId',
//                               isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                           .snapshots(),
//                       builder: (context, mealsSnapshot) {
//                         if (mealsSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const CircularProgressIndicator();
//                         }

//                         final mealDocs = mealsSnapshot.data?.docs ?? [];
//                         final totalCalories = mealDocs.fold<int>(
//                           0,
//                           (sum, doc) {
//                             final data = doc.data() as Map<String, dynamic>;
//                             final calories = (data['calories'] ?? 0) as num;
//                             return sum + calories.toInt();
//                           },
//                         );

//                         return StreamBuilder<QuerySnapshot>(
//                           stream: FirebaseFirestore.instance
//                               .collection('completed_exercises')
//                               .where(
//                                 'completed_at',
//                                 isEqualTo: DateFormat('dd/MM/yyyy')
//                                     .format(selectedDate),
//                               )
//                               .where('user_uid',
//                                   isEqualTo:
//                                       FirebaseAuth.instance.currentUser!.uid)
//                               .snapshots(),
//                           builder: (context, exerciseSnapshot) {
//                             if (exerciseSnapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const CircularProgressIndicator();
//                             }

//                             final exerciseDocs =
//                                 exerciseSnapshot.data?.docs ?? [];
//                             final totalCaloriesExercise =
//                                 exerciseDocs.fold<int>(
//                               0,
//                               (sum, doc) {
//                                 final data = doc.data() as Map<String, dynamic>;
//                                 final calories = (data['calo'] ?? 0) as num;
//                                 return sum + calories.toInt();
//                               },
//                             );

//                             remainingCalories =
//                                 goal - totalCalories + totalCaloriesExercise;

//                             return Text(
//                               '${remainingCalories.toInt()}',
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         const Text("Remaining"),
//       ],
//     );
//   }

//   Widget _buildCalorieDetails() {
//     return FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('user_goal_plans')
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data == null) {
//             return const Text("No data available");
//           }
//           final userDoc = snapshot.data!.data() as Map<String, dynamic>;
//           final baseGoal = userDoc['adjustedCalories'] ?? '0';
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.emoji_events, color: Colors.orange),
//                   const SizedBox(width: 4),
//                   Text("Mục tiêu: ${baseGoal.toInt()}"),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   const Icon(Icons.restaurant, color: Colors.blue),
//                   const SizedBox(width: 4),
//                   StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection('logged_meals')
//                           .where('loggedAt',
//                               isEqualTo:
//                                   DateFormat('yyyy-MM-dd').format(selectedDate))
//                           .where('userId',
//                               isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                           .snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }

//                         final docs = snapshot.data?.docs ?? [];
//                         final totalCalories = docs.fold<int>(
//                           0,
//                           (sum, doc) {
//                             final data = doc.data() as Map<String, dynamic>;
//                             final calories = (data['calories'] ?? 0) as num;
//                             return sum + calories.toInt();
//                           },
//                         );
//                         return Text("Ăn uống: $totalCalories");
//                       }),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   const Icon(Icons.local_fire_department, color: Colors.red),
//                   const SizedBox(width: 4),
//                   StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection('completed_exercises')
//                           .where(
//                             'completed_at',
//                             isEqualTo:
//                                 DateFormat('dd/MM/yyyy').format(selectedDate),
//                           )
//                           .where('user_uid',
//                               isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                           .snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }

//                         final docs = snapshot.data?.docs ?? [];
//                         final totalCaloriesExcercise = docs.fold<int>(
//                           0,
//                           (sum, doc) {
//                             final data = doc.data() as Map<String, dynamic>;
//                             final calories = (data['calo'] ?? 0) as num;
//                             return sum + calories.toInt();
//                           },
//                         );
//                         return Text("Tập luyện: $totalCaloriesExcercise");
//                       }),
//                 ],
//               ),
//             ],
//           );
//         });
//   }

//   Widget _buildNutrientInfo(String nutrient, String value) {
//     return Column(
//       children: [
//         Text(nutrient, style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(value),
//       ],
//     );
//   }

//   Widget _buildExerciseEntry(String title, IconData icon, String value) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.blue),
//       title: Text(title, style: const TextStyle(fontSize: 18)),
//       trailing: Text(value,
//           style: const TextStyle(fontSize: 16, color: Colors.green)),
//     );
//   }

//   Widget _buildMealEntry() {
//     return InkWell(
//       onTap: () {
//         // Navigator.of(context).push(
//         //   MaterialPageRoute(
//         //     builder: (context) => RecipeRecommendationScreen(
//         //       defaultCalories: remainingCalories,
//         //     ),
//         //   ),
//         // );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.orangeAccent.shade200,
//               Colors.orangeAccent.shade100,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: const Row(
//           children: [
//             Icon(Icons.restaurant, color: Colors.white, size: 20),
//             SizedBox(width: 8),
//             Text(
//               'Gợi ý món ăn',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMealTypeSection(String mealType, IconData icon) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: ListTile(
//             leading: Icon(icon, color: Colors.orange),
//             title: Text(mealType, style: const TextStyle(fontSize: 18)),
//             trailing: IconButton(
//               icon: const Icon(
//                 Icons.add_circle,
//                 color: Colors.green,
//                 size: 30,
//               ),
//               onPressed: () {
//                 // Navigator.of(context).push(
//                 //   MaterialPageRoute(
//                 //     builder: (context) => const ProductScanScreen(),
//                 //   ),
//                 // );
//               },
//             ),
//           ),
//         ),
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('logged_meals')
//               .where('type', isEqualTo: mealType)
//               .where('loggedAt',
//                   isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
//               .where('userId',
//                   isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final meals = snapshot.data?.docs ?? [];

//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 24),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: meals.length,
//                 itemBuilder: (context, index) {
//                   final meal = meals[index].data() as Map<String, dynamic>;
//                   return Card(
//                       color: Colors.white,
//                       margin: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: ListTile(
//                         leading: meal['imageUrl'] != null &&
//                                 meal['imageUrl'].toString().startsWith('http')
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(
//                                     12), // Bo góc 12px (có thể thay đổi)
//                                 child: Image.network(
//                                   meal['imageUrl'],
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.cover,
//                                 ),
//                               )
//                             : ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Container(
//                                   width: 50,
//                                   height: 50,
//                                   color:
//                                       Colors.grey.shade200, // Màu nền cho icon
//                                   child: const Icon(
//                                     Icons.fastfood,
//                                     size: 30,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                         title: Text(meal['customName'] ?? meal['originalName'],
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold)),
//                         subtitle: Text(
//                           '${meal['weight']}g',
//                         ),
//                         trailing: Text(
//                           '${meal['calories']} Cal',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) => MealHomeScreen(
//                           //       meal: Meal.fromMap(meal),
//                           //       imageUrl: meal['imageUrl'] ?? '',
//                           //     ),
//                           //   ),
//                           // );
//                         },
//                       ));
//                 },
//               ),
//             );
//           },
//         )
//       ],
//     );
//   }
// }

// Future<String> getGoalFromFirestore(String userId) async {
//   try {
//     final userDoc =
//         FirebaseFirestore.instance.collection('user_goal_plans').doc(userId);

//     // Lấy dữ liệu từ tài liệu
//     final docSnapshot = await userDoc.get();

//     // Kiểm tra xem tài liệu có tồn tại không
//     if (docSnapshot.exists) {
//       // Lấy giá trị của trường 'goal'
//       String goal = docSnapshot.get('goal');
//       return goal;
//     } else {
//       // Tài liệu không tồn tại
//       return 'Không tìm thấy dữ liệu';
//     }
//   } catch (e) {
//     // Xử lý lỗi nếu có
//     return 'Lỗi: $e';
//   }
// }

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  /// Home AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: Center(
        child: Text(
          (selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day)
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
        onPressed: () => setState(() {
          selectedDate = selectedDate.subtract(const Duration(days: 1));
        }),
      ),
      actions: [
        IconButton(
          icon:
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          onPressed: () => setState(() {
            selectedDate = selectedDate.add(const Duration(days: 1));
          }),
        ),
      ],
    );
  }

  /// Display dashboard
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
              const Text(
                "Calories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text("Remaining = Goal - Food + Exercise"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hiển thị hình tròn Calorie
                  _buildCircularCalorieDisplay(-9999),
                  // Thông tin chi tiết Calorie
                  _buildCalorieDetails(),
                ],
              ),
              SizedBox(
                  height: 40, child: Separator(color: Colors.grey.shade400)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutrientInfo("Carbs", "?"),
                  _buildNutrientInfo("Protein", "?"),
                  _buildNutrientInfo("Fat", "?"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display circular calorie
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
                value: totalCalories / 2502, //Fix value
                strokeWidth: 8,
                color: Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
              Center(
                child: Text(
                  '${remainingCalories.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text("Remaining"),
      ],
    );
  }

  /// Display calorie details
  Widget _buildCalorieDetails() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orange),
            const SizedBox(width: 4),
            Text("Mục tiêu: ??????"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.blue),
            const SizedBox(width: 4),
            Text("Ăn uống: ??????"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.red),
            const SizedBox(width: 4),
            Text("Tập luyện: ??????"),
          ],
        ),
      ],
    );
  }

  /// Display nutrient info
  Widget _buildNutrientInfo(String nutrient, String value) {
    return Column(
      children: [
        Text(nutrient, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  /// Display content: morning, noon, evening, snack
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          _buildMealTypeSection("Buổi sáng", Icons.breakfast_dining),
          _buildMealTypeSection("Buổi trưa", Icons.lunch_dining),
          _buildMealTypeSection("Buổi tối", Icons.dinner_dining),
          _buildMealTypeSection("Ăn vặt", Icons.fastfood),
        ],
      ),
    );
  }

  /// Display meal type
  Widget _buildMealTypeSection(String mealType, IconData icon) {
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
            leading: Icon(icon, color: Colors.orange, size: 30,),
            title: Text(mealType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            trailing: GestureDetector(
              onTap: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => const ProductScanScreen(),
                //   ),
                // );
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        // StreamBuilder<QuerySnapshot>(
        //   stream: FirebaseFirestore.instance
        //       .collection('logged_meals')
        //       .where('type', isEqualTo: mealType)
        //       .where('loggedAt',
        //           isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
        //       .where('userId',
        //           isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        //       .snapshots(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(child: CircularProgressIndicator());
        //     }
        //     final meals = snapshot.data?.docs ?? [];

        //     return Container(
        //       margin: const EdgeInsets.symmetric(horizontal: 24),
        //       child: ListView.builder(
        //         shrinkWrap: true,
        //         physics: const NeverScrollableScrollPhysics(),
        //         itemCount: meals.length,
        //         itemBuilder: (context, index) {
        //           final meal = meals[index].data() as Map<String, dynamic>;
        //           return Card(
        //               color: Colors.white,
        //               margin: const EdgeInsets.symmetric(vertical: 4.0),
        //               child: ListTile(
        //                 leading: meal['imageUrl'] != null &&
        //                         meal['imageUrl'].toString().startsWith('http')
        //                     ? ClipRRect(
        //                         borderRadius: BorderRadius.circular(
        //                             12), // Bo góc 12px (có thể thay đổi)
        //                         child: Image.network(
        //                           meal['imageUrl'],
        //                           width: 50,
        //                           height: 50,
        //                           fit: BoxFit.cover,
        //                         ),
        //                       )
        //                     : ClipRRect(
        //                         borderRadius: BorderRadius.circular(12),
        //                         child: Container(
        //                           width: 50,
        //                           height: 50,
        //                           color:
        //                               Colors.grey.shade200, // Màu nền cho icon
        //                           child: const Icon(
        //                             Icons.fastfood,
        //                             size: 30,
        //                             color: Colors.grey,
        //                           ),
        //                         ),
        //                       ),
        //                 title: Text(meal['customName'] ?? meal['originalName'],
        //                     style:
        //                         const TextStyle(fontWeight: FontWeight.bold)),
        //                 subtitle: Text(
        //                   '${meal['weight']}g',
        //                 ),
        //                 trailing: Text(
        //                   '${meal['calories']} Cal',
        //                   style: const TextStyle(
        //                     fontWeight: FontWeight.bold,
        //                     fontSize: 14,
        //                   ),
        //                 ),
        //                 onTap: () {
        //                   // Navigator.push(
        //                   //   context,
        //                   //   MaterialPageRoute(
        //                   //     builder: (context) => MealHomeScreen(
        //                   //       meal: Meal.fromMap(meal),
        //                   //       imageUrl: meal['imageUrl'] ?? '',
        //                   //     ),
        //                   //   ),
        //                   // );
        //                 },
        //               ));
        //         },
        //       ),
        //     );
        //   },
        // )
      ],
    );
  }
}
