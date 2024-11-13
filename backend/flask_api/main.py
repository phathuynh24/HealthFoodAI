from flask import Blueprint, request, jsonify
from utils.image_utils import prepare_image
from models.ai_model import predict_with_model
from models.ai_nutritionix import get_nutrition_info
from models.gemini_model import get_gemini_prediction
from models.gemini_nutritionix import parse_ingredients, calculate_total_nutrition

main = Blueprint('main', __name__)

@main.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    image = request.files['image']
    prepared_image = prepare_image(image)

    # Bước 1: Dự đoán món ăn với mô hình AI chính
    model_predictions, confidence = predict_with_model(prepared_image)
    top_prediction = model_predictions[0]

    class_name = top_prediction['class']
    food_name = " ".join([word.capitalize() for word in class_name.split('_')])

    # Bước 2: Nếu độ tin cậy thấp, sử dụng Gemini để hỗ trợ
    if confidence < 0.9:
        model_name = "gemini-1.5-flash"
        description = (
            "Món tôi đang ăn là hủ tiếu, trong đó có nhiều khoanh mực tươi, "
            "một con tôm, hai quả trứng cút, và một miếng thịt heo. "
            "Nước dùng đậm đà, có mùi thơm của tỏi phi và hành lá. Phía trên có thêm "
            "chút tiêu và hành phi giòn rụm, ăn kèm với các loại rau sống như giá đỗ, "
            "xà lách, và rau thơm."
        )
        gemini_result = get_gemini_prediction(model_name, image, description)

        # Phân tích thành phần từ response của Gemini
        ingredients = parse_ingredients(gemini_result)
        
        if ingredients:
            # Tính tổng dinh dưỡng cho các thành phần
            total_nutrition = calculate_total_nutrition(ingredients)

            return jsonify({
                'prediction': 'Gemini model used due to low confidence',
                'gemini_result': gemini_result,
                'ingredients': ingredients,
                'total_nutrition': total_nutrition
            })
        else:
            return jsonify({
                'prediction': 'Gemini model used due to low confidence',
                'gemini_result': gemini_result,
                'error': 'Could not extract ingredients for nutrition calculation'
            })

    # Bước 3: Nếu độ tin cậy cao, lấy thông tin dinh dưỡng từ mô hình AI
    nutrition_info_model = get_nutrition_info(food_name)

    return jsonify({
        'predictions_model': {
            'class': class_name,
            'score': top_prediction['score'],
            'name': food_name,
            'nutrition_info': nutrition_info_model,
        }
    })
