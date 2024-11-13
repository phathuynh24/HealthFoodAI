import os
import requests
from dotenv import load_dotenv

# Load biến môi trường từ .env
load_dotenv()

NUTRITIONIX_APP_ID = os.getenv("NUTRITIONIX_APP_ID")
NUTRITIONIX_API_KEY = os.getenv("NUTRITIONIX_API_KEY")

# Danh sách các nguyên liệu và khối lượng
ingredients = [
    {"name": "rice noodles", "quantity": "100g"},
    {"name": "pork", "quantity": "100g"},
    {"name": "squid", "quantity": "100g"},
    {"name": "prawn", "quantity": "50g"},
    {"name": "quail eggs", "quantity": "50g"},
    {"name": "garlic", "quantity": "10g"},
    {"name": "spring onion", "quantity": "10g"},
    {"name": "pepper", "quantity": "1g"},
    {"name": "bean sprouts", "quantity": "50g"},
    {"name": "lettuce", "quantity": "50g"}
]

# URL Nutritionix API
url = "https://trackapi.nutritionix.com/v2/natural/nutrients"

# Headers
headers = {
    "x-app-id": NUTRITIONIX_APP_ID,
    "x-app-key": NUTRITIONIX_API_KEY,
    "Content-Type": "application/json"
}

# Tổng hợp dữ liệu dinh dưỡng
total_nutrition = {
    "calories": 0,
    "protein": 0,
    "total_fat": 0,
    "total_carbohydrate": 0
}

# Gửi yêu cầu cho từng nguyên liệu
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

# In ra tổng lượng dinh dưỡng
print("Tổng dinh dưỡng của món ăn:")
print(f"Calories: {total_nutrition['calories']} kcal")
print(f"Protein: {total_nutrition['protein']} g")
print(f"Total Fat: {total_nutrition['total_fat']} g")
print(f"Total Carbohydrate: {total_nutrition['total_carbohydrate']} g")
