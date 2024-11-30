# Dữ liệu món ăn mẫu (có thể lấy từ file hoặc cơ sở dữ liệu)
meals = [
    {
        "meal_name": "Salad cá hồi",
        "nutritional_info": {
            "calories": 250,
            "sodium": 500,
            "cholesterol": 30
        },
        "category": "low_calorie"
    },
    {
        "meal_name": "Mì xào thập cẩm",
        "nutritional_info": {
            "calories": 650,
            "sodium": 1200,
            "cholesterol": 80
        },
        "category": "high_sodium"
    },
    {
        "meal_name": "Cháo gà",
        "nutritional_info": {
            "calories": 300,
            "sodium": 800,
            "cholesterol": 60
        },
        "category": "low_cholesterol"
    }
]

# Cảnh báo về sức khỏe (có thể lấy từ kết quả phân tích dinh dưỡng)
warnings = [
    "Cảnh báo: Bạn đã tiêu thụ quá nhiều calo trong tuần.",
    "Cảnh báo: Lượng sodium trong tuần quá cao.",
    "Cảnh báo: Lượng cholesterol trong tuần quá cao."
]

# Hàm gợi ý món ăn dựa trên cảnh báo
def suggest_meals_based_on_warnings(warnings, meals):
    suggested_meals = []

    # Gợi ý các món ăn dựa trên cảnh báo
    if "quá nhiều calo" in warnings[0]:
        suggested_meals.append("Gợi ý món ăn ít calo: Salad cá hồi")
    
    if "quá cao sodium" in warnings[1]:
        suggested_meals.append("Gợi ý món ăn ít muối: Cháo gà")
    
    if "quá cao cholesterol" in warnings[2]:
        suggested_meals.append("Gợi ý món ăn ít cholesterol: Salad cá hồi")

    return suggested_meals

# Lấy gợi ý món ăn dựa trên cảnh báo
suggestions = suggest_meals_based_on_warnings(warnings, meals)

# In ra gợi ý món ăn
print("Gợi ý món ăn cho bạn:")
for suggestion in suggestions:
    print(suggestion)
