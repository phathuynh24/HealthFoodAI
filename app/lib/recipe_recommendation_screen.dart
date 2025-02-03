import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeRecommendationScreen extends StatefulWidget {
  @override
  _RecipeRecommendationScreenState createState() =>
      _RecipeRecommendationScreenState();
}

class _RecipeRecommendationScreenState
    extends State<RecipeRecommendationScreen> {
  final String backendUrl =
      "http://10.0.108.213:5001/recommendation/suggest-recipes";
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = false;

  Future<void> fetchRecipes() async {
    final body = jsonEncode({
      "userId": "12345",
      "preferences": {
        "cuisine": "Asian",
        "spicy": true,
        "sweet": false
      },
      "nutrition": {
        "calories": 3000,
        "protein": 50,
        "fat": 60,
        "carbs": 300
      }
    });

    try {
      setState(() {
        isLoading = true;
      });

      print('Request URL: $backendUrl');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recipes = List<Map<String, dynamic>>.from(data['recipes']);
        });
      } else {
        print('Failed to load recipes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(recipe['title'] ?? 'No Title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (recipe['image'] != null)
                Image.network(recipe['image'], height: 150),
              const SizedBox(height: 10),
              Text(recipe['summary'] ?? 'No Summary'),
              const SizedBox(height: 10),
              if (recipe['readyInMinutes'] != null)
                Text('Ready in: ${recipe['readyInMinutes']} minutes'),
              if (recipe['servings'] != null)
                Text('Servings: ${recipe['servings']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Recommendation')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? Center(
                  child: ElevatedButton(
                    onPressed: fetchRecipes,
                    child: const Text('Fetch Recipes'),
                  ),
                )
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      leading: recipe['image'] != null
                          ? Image.network(recipe['image'], width: 50, height: 50)
                          : const Icon(Icons.fastfood),
                      title: Text(recipe['title'] ?? 'No Title'),
                      subtitle: Text(
                        recipe['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ??
                            'No Summary',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => showRecipeDetails(context, recipe),
                    );
                  },
                ),
    );
  }
}
