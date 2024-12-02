
import 'package:app/orther/themes.dart';
import 'package:app/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductScanScreen extends StatefulWidget {
  @override
  _ProductScanScreenState createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  File? _image;

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _navigateToScreen2();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _navigateToScreen2();
    }
  }

  void _navigateToTextEntryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextEntryScreen(),
      ),
    );
  }

  void _navigateToScreen2() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Screen2(image: _image!),
      ),
    );
  }

  int _selectedIndex = 1;

  void _onBottomNavigationBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _pickImageFromGallery();
    } else if (index == 1) {
      _pickImageFromCamera();
    } else if (index == 2) {
      _navigateToTextEntryScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Snap a photo'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Snap a food photo to analyze and log the calories.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            IconButton(
              iconSize: 80,
              icon: Icon(Icons.camera_alt, color: Themes.gradientDeepClr),
              onPressed: _pickImageFromCamera,
            ),
            Text(
              "Analyze & Log",
              style: TextStyle(fontSize: 16, color: Themes.gradientLightClr),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationBarTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: "Album",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Snap",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: "Text Entry",
          ),
        ],
        selectedItemColor: Themes.gradientDeepClr,
      ),
    );
  }
}

class TextEntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Enter Description'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/describe_food.jpg'),
            SizedBox(height: 40),
            TextField(
              // controller: ,
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
                  onPressed: () {},
                  tooltip: "Send",
                ),
              ),
              maxLines: 5,
              minLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}