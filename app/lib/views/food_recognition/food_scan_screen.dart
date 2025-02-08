import 'dart:io';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/views/main_screen.dart';
import 'package:app/views/food_recognition/favorite_meals.dart';
import 'package:app/views/food_recognition/food_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/widgets/custom_app_bar.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  File? _image;
  int _selectedIndex = 1;

  /// Pick an image from the camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _processPickedImage(pickedFile);
  }

  /// Pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _processPickedImage(pickedFile);
  }

  /// Process and navigate after selecting an image
  void _processPickedImage(XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _navigateToProductScreen();
    }
  }

  /// Navigate to the meal detail screen
  void _navigateToProductScreen() {
    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodReviewScreen(image: _image!),
        ),
      );
    }
  }

  /// Navigate to saved favorite meals
  void _navigateToFavoriteMealsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoriteMealsScreen()),
    );
  }

  /// Handle bottom navigation taps
  void _onBottomNavigationBarTapped(int index) {
    if (index == 0) {
      _pickImageFromGallery();
    } else if (index == 2) {
      _navigateToFavoriteMealsScreen();
    }

    // Nếu index là 0 hoặc 2, luôn đặt về tab trung tâm (1)
    setState(() {
      _selectedIndex = (index == 0 || index == 2) ? 1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable back button
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: "Scan món ăn"),
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Instructional Text (Clear Guide for Users)
                const Text(
                  "📷 Hãy chụp ảnh món ăn để ứng dụng phân tích thông tin dinh dưỡng.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Nhấn vào biểu tượng bên dưới ngay!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Camera Illustration (Clickable)
                GestureDetector(
                  onTap: _pickImageFromCamera,
                  child: Image.asset(
                    "assets/camera_scan.png",
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavigationBarTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_album),
              label: "Album",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: "Chụp ảnh",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Đã lưu",
            ),
          ],
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
