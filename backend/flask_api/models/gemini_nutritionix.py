# # gemini_nutritionx.py
# import os
# import re
# import requests
# from dotenv import load_dotenv

# # Load biến môi trường từ .env
# load_dotenv()

# NUTRITIONIX_APP_ID = os.getenv("NUTRITIONIX_APP_ID")
# NUTRITIONIX_API_KEY = os.getenv("NUTRITIONIX_API_KEY")

# # URL Nutritionix API cho phân tích từng thành phần
# url = "https://trackapi.nutritionix.com/v2/natural/nutrients"

# # Headers cho yêu cầu API
# headers = {
#     "x-app-id": NUTRITIONIX_APP_ID,
#     "x-app-key": NUTRITIONIX_API_KEY,
#     "Content-Type": "application/json"
# }

# def parse_ingredients(gemini_response):
#     """
#     Phân tích danh sách nguyên liệu từ response của Gemini API và đảm bảo tất cả đều có đơn vị gram (g).
#     """
#     ingredients = []
#     match = re.search(r'Ingredients: (.+)', gemini_response)
#     if match:
#         ingredients_list = match.group(1).split(", ")
#         for item in ingredients_list:
#             ingredient_match = re.match(r'(.+?) \(\~(\d+)g\)', item)
#             if ingredient_match:
#                 name = ingredient_match.group(1).strip()
#                 quantity = f"{ingredient_match.group(2).strip()} g"
#                 ingredients.append({"name": name, "quantity": quantity})
#             else:
#                 print(f"Lưu ý: '{item}' không có đơn vị gram (g) và sẽ bị bỏ qua.")
#     return ingredients

# def calculate_total_nutrition(ingredients):
#     """
#     Tính tổng dinh dưỡng từ Nutritionix cho từng nguyên liệu và trả lại chi tiết cho mỗi thành phần.
#     """
#     total_nutrition = {
#         "calories": 0,
#         "protein": 0,
#         "total_fat": 0,
#         "total_carbohydrate": 0
#     }
#     detailed_nutrition = []  # Danh sách chi tiết dinh dưỡng của từng nguyên liệu

#     for ingredient in ingredients:
#         data = {
#             "query": f"{ingredient['quantity']} {ingredient['name']}",
#             "timezone": "US/Eastern"
#         }
#         response = requests.post(url, headers=headers, json=data)

#         if response.status_code == 200:
#             nutrition_data = response.json()["foods"][0]
            
#             # Lấy thông tin dinh dưỡng cho từng thành phần
#             ingredient_nutrition = {
#                 "name": ingredient['name'],
#                 "quantity": ingredient['quantity'],
#                 "calories": nutrition_data.get("nf_calories", 0),
#                 "protein": nutrition_data.get("nf_protein", 0),
#                 "total_fat": nutrition_data.get("nf_total_fat", 0),
#                 "total_carbohydrate": nutrition_data.get("nf_total_carbohydrate", 0)
#             }
#             detailed_nutrition.append(ingredient_nutrition)

#             # Cộng giá trị của từng chất dinh dưỡng vào tổng
#             total_nutrition["calories"] += ingredient_nutrition["calories"]
#             total_nutrition["protein"] += ingredient_nutrition["protein"]
#             total_nutrition["total_fat"] += ingredient_nutrition["total_fat"]
#             total_nutrition["total_carbohydrate"] += ingredient_nutrition["total_carbohydrate"]
#         else:
#             print(f"Không thể lấy dữ liệu cho {ingredient['name']}")

#     # Làm tròn giá trị tổng dinh dưỡng
#     total_nutrition["calories"] = round(total_nutrition["calories"], 1)
#     total_nutrition["protein"] = round(total_nutrition["protein"], 1)
#     total_nutrition["total_fat"] = round(total_nutrition["total_fat"], 1)
#     total_nutrition["total_carbohydrate"] = round(total_nutrition["total_carbohydrate"], 1)

#     return {
#         "total_nutrition": total_nutrition,
#         "detailed_nutrition": detailed_nutrition
#     }

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

def parse_ingredients(gemini_response):
    """
    Phân tích danh sách nguyên liệu từ response của Gemini API và đảm bảo tất cả đều có đơn vị gram (g).
    """
    ingredients = []
    match = re.search(r'Ingredients: (.+)', gemini_response)
    if match:
        ingredients_list = match.group(1).split(", ")
        for item in ingredients_list:
            ingredient_match = re.match(r'(.+?) \(\~(\d+)g\)', item)
            if ingredient_match:
                name = ingredient_match.group(1).strip()
                quantity = f"{ingredient_match.group(2).strip()} g"
                ingredients.append({"name": name, "quantity": quantity})
            else:
                print(f"Lưu ý: '{item}' không có đơn vị gram (g) và sẽ bị bỏ qua.")
    return ingredients

def calculate_total_nutrition(ingredients):
    """
    Tính tổng dinh dưỡng từ Nutritionix cho từng nguyên liệu và trả lại chi tiết cho mỗi thành phần.
    """
    total_nutrition = {
        "calories": 0,
        "protein": 0,
        "total_fat": 0,
        "total_carbohydrate": 0,
        "sodium": 0,
        "cholesterol": 0,
        "dietary_fiber": 0,
        "sugars": 0,
        "potassium": 0
    }
    detailed_nutrition = []  # Danh sách chi tiết dinh dưỡng của từng nguyên liệu

    for ingredient in ingredients:
        data = {
            "query": f"{ingredient['quantity']} {ingredient['name']}",
            "timezone": "US/Eastern"
        }
        response = requests.post(url, headers=headers, json=data)

        if response.status_code == 200:
            nutrition_data = response.json()["foods"][0]
            
            # Lấy thông tin dinh dưỡng cho từng thành phần
            ingredient_nutrition = {
                "name": ingredient['name'],
                "quantity": ingredient['quantity'],
                "calories": nutrition_data.get("nf_calories", 0),
                "protein": nutrition_data.get("nf_protein", 0),
                "total_fat": nutrition_data.get("nf_total_fat", 0),
                "total_carbohydrate": nutrition_data.get("nf_total_carbohydrate", 0),
                "sodium": nutrition_data.get("nf_sodium", 0),
                "cholesterol": nutrition_data.get("nf_cholesterol", 0),
                "dietary_fiber": nutrition_data.get("nf_dietary_fiber", 0),
                "sugars": nutrition_data.get("nf_sugars", 0),
                "potassium": nutrition_data.get("nf_potassium", 0),
            }
            detailed_nutrition.append(ingredient_nutrition)

            # Cộng giá trị của từng chất dinh dưỡng vào tổng
            total_nutrition["calories"] += ingredient_nutrition["calories"]
            total_nutrition["protein"] += ingredient_nutrition["protein"]
            total_nutrition["total_fat"] += ingredient_nutrition["total_fat"]
            total_nutrition["total_carbohydrate"] += ingredient_nutrition["total_carbohydrate"]
            total_nutrition["sodium"] += ingredient_nutrition["sodium"]
            total_nutrition["cholesterol"] += ingredient_nutrition["cholesterol"]
            total_nutrition["dietary_fiber"] += ingredient_nutrition["dietary_fiber"]
            total_nutrition["sugars"] += ingredient_nutrition["sugars"]
            total_nutrition["potassium"] += ingredient_nutrition["potassium"]
        else:
            print(f"Không thể lấy dữ liệu cho {ingredient['name']}")

    # Làm tròn giá trị tổng dinh dưỡng
    total_nutrition["calories"] = round(total_nutrition["calories"], 1)
    total_nutrition["protein"] = round(total_nutrition["protein"], 1)
    total_nutrition["total_fat"] = round(total_nutrition["total_fat"], 1)
    total_nutrition["total_carbohydrate"] = round(total_nutrition["total_carbohydrate"], 1)
    total_nutrition["sodium"] = round(total_nutrition["sodium"], 1)
    total_nutrition["cholesterol"] = round(total_nutrition["cholesterol"], 1)
    total_nutrition["dietary_fiber"] = round(total_nutrition["dietary_fiber"], 1)
    total_nutrition["sugars"] = round(total_nutrition["sugars"], 1)
    total_nutrition["potassium"] = round(total_nutrition["potassium"], 1)

    return {
        "total_nutrition": total_nutrition,
        "detailed_nutrition": detailed_nutrition
    }
