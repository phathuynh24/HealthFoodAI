import pytest
import requests
import json

# Sử dụng API key trực tiếp
SPOONACULAR_API_KEY = "60d38f22a699426986793ae315c8be0e"

def test_spoonacular_complex_search():
    """
    Kiểm tra API `complexSearch` của Spoonacular với yêu cầu cơ bản.
    """
    # URL của Spoonacular API
    url = "https://api.spoonacular.com/recipes/complexSearch"

    # Tham số gửi đến API
    params = {
        "apiKey": SPOONACULAR_API_KEY,
        "maxCalories": 3000,
        "number": 2,
        "diet": "vegetarian",               # Chế độ ăn kiêng
        "intolerances": "dairy,peanut",     # Dị ứng thực phẩm
        "cuisine": "Mexican",               # Loại ẩm thực (ví dụ: Mexico)
        "includeIngredients": "chili,lime", # Thêm nguyên liệu để phù hợp khẩu vị
        "excludeIngredients": "sugar"       # Loại bỏ nguyên liệu không mong muốn
    }

    # Gửi yêu cầu GET đến API
    response = requests.get(url, params=params)

    # Kiểm tra mã trạng thái phản hồi
    assert response.status_code == 200, f"API returned status code {response.status_code}"

    # Phân tích phản hồi
    response_data = response.json()

    # In phản hồi ra terminal
    print(json.dumps(response_data, indent=4))

    # Kiểm tra nội dung phản hồi
    assert "results" in response_data, "API response does not contain 'results'"
    assert len(response_data["results"]) > 0, "No recipes found in the API response"
