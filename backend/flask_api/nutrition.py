from flask import Blueprint, request, jsonify
from utils.image_utils import prepare_image
from models.ai_model import predict_with_model
from models.ai_nutritionix import get_nutrition_info
from models.gemini_model import get_gemini_prediction
from models.gemini_nutritionix import parse_ingredients, calculate_total_nutrition
from models.gemini_warning import generate_analysis_data, get_gemini_warning, get_normal_warning

nutrition = Blueprint('nutrition', __name__)

@nutrition.route("/nutrition/predict", methods=["POST"])
def predict():
    # Lấy thông tin từ request
    description = request.form.get("description")
    image = request.files.get('image')
    blood_pressure = request.form.get("blood_pressure")  # {'systolic': x, 'diastolic': y}
    blood_sugar = request.form.get("blood_sugar")  # Mức đường huyết
    warnings = ''

    # Case 1: Only description is provided, use Gemini for text-based prediction
    if description and not image:
        model_name = "gemini-1.5-flash"
        gemini_result = get_gemini_prediction(model_name, description=description)

        # Parse ingredients and calculate nutrition
        ingredients = parse_ingredients(gemini_result)
        if ingredients:
            total_nutrition = calculate_total_nutrition(ingredients)

            # Lấy cảnh báo sức khỏe từ thông tin dinh dưỡng và tình trạng người dùng
            if (blood_pressure is not None) and (blood_sugar is not None):
                analysis_data = generate_analysis_data(total_nutrition['total_nutrition'], blood_pressure, blood_sugar)
                warnings = get_gemini_warning(analysis_data)
            else:
                warnings = get_normal_warning(total_nutrition['total_nutrition'])

            return jsonify({
                'prediction': 'Gemini model used for text description',
                'gemini_result': gemini_result,
                'ingredients': ingredients,
                'total_nutrition': total_nutrition,
                'warnings': warnings  # Thêm cảnh báo vào response 
            })
        else:
            return jsonify({
                'prediction': 'Gemini model used for text description',
                'gemini_result': gemini_result,
                'error': 'Could not extract ingredients for nutrition calculation'
            })

    # Case 2: Image is provided, proceed with AI model prediction
    if image:
        prepared_image = prepare_image(image)

        # Predict with the primary AI model
        confidence = 0.0
        if not description:
            model_predictions, confidence = predict_with_model(prepared_image)
            top_prediction = model_predictions[0]
            class_name = top_prediction['class']
            food_name = " ".join([word.capitalize() for word in class_name.split('_')])

        # Nếu confidence thấp, sử dụng Gemini làm fallback
        if confidence < 0.9:
            model_name = "gemini-1.5-flash"
            gemini_result = get_gemini_prediction(model_name, image, description=description)

            # Parse ingredients and calculate nutrition
            ingredients = parse_ingredients(gemini_result)
            if ingredients:
                total_nutrition = calculate_total_nutrition(ingredients)
                if (blood_pressure is not None) and (blood_sugar is not None):
                    analysis_data = generate_analysis_data(total_nutrition['total_nutrition'], blood_pressure, blood_sugar)
                    warnings = get_gemini_warning(analysis_data)
                else:
                    warnings = get_normal_warning(total_nutrition['total_nutrition'])

                return jsonify({
                    'prediction': 'Gemini model used due to low confidence',
                    'gemini_result': gemini_result,
                    'ingredients': ingredients,
                    'total_nutrition': total_nutrition,
                    'warnings': warnings  # Thêm cảnh báo vào response
                })
            else:
                return jsonify({
                    'prediction': 'Gemini model used due to low confidence',
                    'gemini_result': gemini_result,
                    'error': 'Could not extract ingredients for nutrition calculation'
                })

        # Nếu confidence cao, lấy thông tin dinh dưỡng từ AI model
        nutrition_info_model = get_nutrition_info(food_name)
        if (blood_pressure is not None) and (blood_sugar is not None):
            analysis_data = generate_analysis_data(total_nutrition['total_nutrition'], blood_pressure, blood_sugar)
            warnings = get_gemini_warning(analysis_data)
        else :
            warnings = get_normal_warning(total_nutrition['total_nutrition'])

        return jsonify({
            'predictions_model': {
                'name': food_name,
                'class': class_name,
                'name_vi': top_prediction['class_vi'],
                'score': top_prediction['score'],
                'nutrition_info': nutrition_info_model,
            },
            'warnings': warnings  # Thêm cảnh báo vào response
        })

    # Error handling: If neither image nor description is provided
    return jsonify({'error': 'No image or description provided'}), 400
