import json
from collections import Counter

# Lấy dữ liệu từ file JSON
def get_meal_history_from_json(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        data = json.load(file)
        return data['meal_history']

# Đọc dữ liệu
meal_history = get_meal_history_from_json("../mocks/meal_history.json")

# Các ngưỡng dinh dưỡng
DAILY_CALORIE_LIMIT = 2500  # 2500 calo mỗi ngày
WEEKLY_CALORIE_LIMIT = DAILY_CALORIE_LIMIT * 7  # 17500 calo mỗi tuần
DAILY_SODIUM_LIMIT = 2300  # 2300mg sodium mỗi ngày
WEEKLY_SODIUM_LIMIT = DAILY_SODIUM_LIMIT * 7  # 16100mg sodium mỗi tuần
DAILY_CHOLESTEROL_LIMIT = 300  # 300mg cholesterol mỗi ngày
WEEKLY_CHOLESTEROL_LIMIT = DAILY_CHOLESTEROL_LIMIT * 7  # 2100mg cholesterol mỗi tuần

# Hàm tạo cảnh báo
def generate_meal_warning(meal_history):
    total_calories = 0
    total_sodium = 0
    total_cholesterol = 0

    meal_count = Counter()

    # Đếm và tính toán tổng dinh dưỡng
    for day in meal_history:
        for meal in day['meals']:
            total_calories += meal["calories"]
            total_sodium += meal["sodium"]
            total_cholesterol += meal["cholesterol"]
            meal_count[meal["meal_name"]] += 1

    warnings = []

    # Sửa lỗi bằng cách chuyển các giá trị int thành str
    print(str(total_calories) + " so với " + str(WEEKLY_CALORIE_LIMIT))
    print(str(total_sodium) + " so với " + str(WEEKLY_SODIUM_LIMIT))
    print(str(total_cholesterol) + " so với " + str(WEEKLY_CHOLESTEROL_LIMIT))
    print(meal_count)

    # Cảnh báo nếu tổng calo vượt quá ngưỡng
    if total_calories > WEEKLY_CALORIE_LIMIT:
        warnings.append(f"Cảnh báo: Bạn đã tiêu thụ quá nhiều calo trong tuần qua. Tổng calo là {total_calories} calo, vượt mức khuyến nghị {WEEKLY_CALORIE_LIMIT} calo.")

    # Cảnh báo nếu tổng sodium vượt quá ngưỡng
    if total_sodium > WEEKLY_SODIUM_LIMIT:
        warnings.append(f"Cảnh báo: Bạn đã tiêu thụ quá nhiều sodium trong tuần qua. Tổng sodium là {total_sodium}mg, vượt mức khuyến nghị {WEEKLY_SODIUM_LIMIT}mg.")

    # Cảnh báo nếu tổng cholesterol vượt quá ngưỡng
    if total_cholesterol > WEEKLY_CHOLESTEROL_LIMIT:
        warnings.append(f"Cảnh báo: Bạn đã tiêu thụ quá nhiều cholesterol trong tuần qua. Tổng cholesterol là {total_cholesterol}mg, vượt mức khuyến nghị {WEEKLY_CHOLESTEROL_LIMIT}mg.")

    # Cảnh báo nếu có món ăn xuất hiện quá nhiều trong tuần
    for meal_name, count in meal_count.items():
        if count >= 7:  # Nếu món ăn này xuất hiện 7 lần (ăn mỗi ngày)
            warnings.append(f"Cảnh báo: Bạn đã ăn món {meal_name} quá nhiều trong tuần qua. Món ăn này xuất hiện {count} lần.")

    # Nhận xét tổng thể
    if total_calories <= WEEKLY_CALORIE_LIMIT and total_sodium <= WEEKLY_SODIUM_LIMIT and total_cholesterol <= WEEKLY_CHOLESTEROL_LIMIT:
        warnings.append("Chế độ ăn của bạn trong tuần qua là hợp lý. Không có cảnh báo về dinh dưỡng.")
    else:
        warnings.append("Chế độ ăn của bạn cần cải thiện. Cần giảm lượng calo, sodium hoặc cholesterol.")

    return warnings

# Phân tích và tạo cảnh báo
warnings = generate_meal_warning(meal_history)
for warning in warnings:
    print(warning)

