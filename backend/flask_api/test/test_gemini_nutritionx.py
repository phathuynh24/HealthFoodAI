import os
import re
import requests
from dotenv import load_dotenv

# Load biến môi trường từ .env
load_dotenv()

NUTRITIONIX_APP_ID = os.getenv("NUTRITIONIX_APP_ID")
NUTRITIONIX_API_KEY = os.getenv("NUTRITIONIX_API_KEY")

# URL Nutritionix API cho phân tích từng thành phần
url = "https://trackapi.nutritionix.com/v2/natural/nutrients"

# Headers cho yêu cầu API
headers = {
    "x-app-id": NUTRITIONIX_APP_ID,
    "x-app-key": NUTRITIONIX_API_KEY,
    "Content-Type": "application/json"
}

# Ví dụ response từ Gemini
gemini_response = 'Vietnamese: Hủ tiếu,\nEnglish: Rice noodles soup,\nIngredients: Rice noodles (~100g), pork (~100g), squid (~100g), prawn (~50g), quail eggs (~50g), garlic (~10g), spring onion (~10g), pepper (~1g), bean sprouts (~50g), lettuce (~50g).'

# Tách các thành phần và khối lượng từ response của Gemini
def parse_ingredients(gemini_response):
    ingredients = []
    match = re.search(r'Ingredients: (.+)', gemini_response)
    if match:
        ingredients_list = match.group(1).split(", ")
        for item in ingredients_list:
            # Tách tên nguyên liệu và khối lượng
            ingredient_match = re.match(r'(.+?) \(\~(\d+g)\)', item)
            if ingredient_match:
                name = ingredient_match.group(1).strip()
                quantity = ingredient_match.group(2).strip()
                ingredients.append({"name": name, "quantity": quantity})
    return ingredients

# Lấy danh sách nguyên liệu từ response của Gemini
ingredients = parse_ingredients(gemini_response)

# Tổng hợp dữ liệu dinh dưỡng
total_nutrition = {
    "calories": 0,
    "protein": 0,
    "total_fat": 0,
    "total_carbohydrate": 0
}

# Hàm tính tổng dinh dưỡng từ Nutritionix cho từng nguyên liệu
def calculate_total_nutrition(ingredients):
    global total_nutrition
    for ingredient in ingredients:
        data = {
            "query": f"{ingredient['quantity']} {ingredient['name']}",
            "timezone": "US/Eastern"
        }
        response = requests.post(url, headers=headers, json=data)

        if response.status_code == 200:
            nutrition_data = response.json()["foods"][0]
            
            # Cộng giá trị của từng chất dinh dưỡng vào tổng
            total_nutrition["calories"] += nutrition_data.get("nf_calories", 0)
            total_nutrition["protein"] += nutrition_data.get("nf_protein", 0)
            total_nutrition["total_fat"] += nutrition_data.get("nf_total_fat", 0)
            total_nutrition["total_carbohydrate"] += nutrition_data.get("nf_total_carbohydrate", 0)
        else:
            print(f"Không thể lấy dữ liệu cho {ingredient['name']}")

# Gọi hàm để tính tổng dinh dưỡng
calculate_total_nutrition(ingredients)

# In ra tổng lượng dinh dưỡng
print("Tổng dinh dưỡng của món ăn:")
print(f"Calories: {total_nutrition['calories']} kcal")
print(f"Protein: {total_nutrition['protein']} g")
print(f"Total Fat: {total_nutrition['total_fat']} g")
print(f"Total Carbohydrate: {total_nutrition['total_carbohydrate']} g")
