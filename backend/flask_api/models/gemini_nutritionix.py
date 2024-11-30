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
    # Khởi tạo danh sách nguyên liệu
    ingredients = []

    # Lọc phần "Ingredients" từ gemini_response
    ingredients_section = gemini_response.split("Ingredients:")[1]  # Lấy phần sau "Ingredients:"
    ingredients_section = ingredients_section.strip()  # Loại bỏ khoảng trắng thừa

    # Sử dụng regex để phân tích các nguyên liệu có dạng: Tên món tiếng Anh|Tên món tiếng Việt (~số gram)
    matches = re.findall(r'([^|]+)\|([^~]+) \(\~(\d+)g\)', ingredients_section)

    for match_item in matches:
        name_english = match_item[0].strip()  # Tên tiếng Anh
        name_vietnamese = match_item[1].strip()  # Tên tiếng Việt
        quantity = f"{match_item[2]} g"  # Số gram (đơn vị gram)

        # Đảm bảo không có dấu phẩy thừa trong name_english hoặc name_vietnamese
        if name_english and name_vietnamese:  # Chỉ thêm nếu tên tiếng Anh và tiếng Việt đều có giá trị
            ingredients.append({
                "name_english": name_english.strip(", "),  # Loại bỏ dấu phẩy thừa
                "name_vietnamese": name_vietnamese.strip(", "),  # Loại bỏ dấu phẩy thừa
                "quantity": quantity
            })
    
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
            "query": f"{ingredient['quantity']} {ingredient['name_english']}",  # Sử dụng name_english ở đây
            "timezone": "US/Eastern"
        }
        response = requests.post(url, headers=headers, json=data)

        if response.status_code == 200:
            nutrition_data = response.json().get("foods", [{}])[0]  # Lấy dữ liệu an toàn

            # Lấy thông tin dinh dưỡng cho từng thành phần, thay thế None bằng 0
            ingredient_nutrition = {
                "name": ingredient['name_english'],
                "quantity": ingredient['quantity'],
                "calories": nutrition_data.get("nf_calories", 0) or 0,
                "protein": nutrition_data.get("nf_protein", 0) or 0,
                "total_fat": nutrition_data.get("nf_total_fat", 0) or 0,
                "total_carbohydrate": nutrition_data.get("nf_total_carbohydrate", 0) or 0,
                "sodium": nutrition_data.get("nf_sodium", 0) or 0,
                "cholesterol": nutrition_data.get("nf_cholesterol", 0) or 0,
                "dietary_fiber": nutrition_data.get("nf_dietary_fiber", 0) or 0,
                "sugars": nutrition_data.get("nf_sugars", 0) or 0,
                "potassium": nutrition_data.get("nf_potassium", 0) or 0,
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
            print(f"Không thể lấy dữ liệu cho {ingredient['name_english']}")

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
