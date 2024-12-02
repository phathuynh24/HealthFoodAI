import 'package:flutter/material.dart';

class NutritionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chicken Noodle Soup"),
        leading: Icon(Icons.home),
        actions: [
          Icon(Icons.share),
          DropdownButton<String>(
            items: [
              DropdownMenuItem(
                value: "Snacks",
                child: Text("Snacks"),
              ),
            ],
            onChanged: (value) {},
            icon: Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chicken Noodle Soup",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "CaloScanAI provides calorie and nutritional estimates intended to be helpful for reference purposes only. They should not be taken as completely precise figures and should not replace professional healthcare advice.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Learn More",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 16),
            // Nutrition Estimate Table
            Container(
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Food item",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Weight/Volume",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Calories",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Chicken Noodle Soup"),
                        Text("300ml"),
                        Text("200Cal"),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total"),
                        Text("300ml"),
                        Text("200Cal"),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.yellow[100],
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nutrient",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        _buildNutrientRow("Total Carbs", "20g"),
                        _buildNutrientRow("Total Protein", "15g"),
                        _buildNutrientRow("Total Fat", "5g"),
                        _buildNutrientRow("Total Dietary Fiber", "2g"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Refine Result"),
            ),
            SizedBox(height: 16),
            Text(
              "The Amount Eaten (Serving)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {},
                ),
                Text("1 Serving"),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  child: Text("Try another"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.yellow[700],
                  ),
                  child: Text("Log This Meal"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String nutrient, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nutrient),
          Text(amount),
        ],
      ),
    );
  }
}