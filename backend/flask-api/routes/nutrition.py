import os
import requests
from dotenv import load_dotenv
from flask import jsonify

# Load biến môi trường từ .env
load_dotenv()

NUTRITIONIX_APP_ID = os.getenv("NUTRITIONIX_APP_ID")
NUTRITIONIX_API_KEY = os.getenv("NUTRITIONIX_API_KEY")

def get_nutrition_info(food_name):
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
        nutrition_data = response.json()
        return nutrition_data['foods'][0]  # Lấy thông tin dinh dưỡng của món ăn đầu tiên
    else:
        return {"error": "Unable to fetch nutrition information"}
