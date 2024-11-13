# model_nutritionx.py
import os
import requests
from dotenv import load_dotenv

# Load biến môi trường từ .env
load_dotenv()

NUTRITIONIX_APP_ID = os.getenv("NUTRITIONIX_APP_ID")
NUTRITIONIX_API_KEY = os.getenv("NUTRITIONIX_API_KEY")

def get_nutrition_info(food_name):
    """
    Gửi yêu cầu đến Nutritionix API để lấy thông tin dinh dưỡng cho một món ăn.
    """
    url = "https://trackapi.nutritionix.com/v2/natural/nutrients"
    headers = {
        "x-app-id": NUTRITIONIX_APP_ID,
        "x-app-key": NUTRITIONIX_API_KEY,
        "Content-Type": "application/json"
    }
    data = {
        "query": food_name,
        "timezone": "US/Eastern"
    }

    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 200:
        nutrition_data = response.json()["foods"][0]

        # Lọc các thông tin cần thiết từ nutrition_info
        filtered_data = {
            "name": nutrition_data.get("food_name", "N/A"),
            "calories": nutrition_data.get("nf_calories", "N/A"),
            "protein": nutrition_data.get("nf_protein", "N/A"),
            "total_fat": nutrition_data.get("nf_total_fat", "N/A"),
            "total_carbohydrate": nutrition_data.get("nf_total_carbohydrate", "N/A"),
            "serving_qty": nutrition_data.get("serving_qty", "N/A"),
            "serving_unit": nutrition_data.get("serving_unit", "N/A"),
            "serving_weight_grams": nutrition_data.get("serving_weight_grams", "N/A"),
            "highres_image_url": nutrition_data.get("photo", {}).get("highres", "N/A"),
        }

        return filtered_data
    else:
        return {"error": "Unable to fetch nutrition information"}
