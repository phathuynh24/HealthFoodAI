import re
from flask import Blueprint, request, jsonify
from models.ai_model import predict_with_model
from models.gemini_model import get_gemini_prediction
from utils.image_utils import prepare_image
from routes.nutrition import get_nutrition_info
from fuzzywuzzy import process

main = Blueprint('main', __name__)

def find_closest_food_name(food_name, nutrition_data):
    if isinstance(nutrition_data, str):
        nutrition_data_list = nutrition_data.split(',')
    else:
        return None
    closest_match = process.extractOne(food_name, nutrition_data_list)
    return {"name": closest_match[0], "score": closest_match[1]} if closest_match and closest_match[1] > 80 else None

@main.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    image = request.files['image']
    prepared_image = prepare_image(image)

    model_predictions, confidence = predict_with_model(prepared_image)
    top_prediction = model_predictions[0]

    class_name = top_prediction['class']
    food_name = " ".join([word.capitalize() for word in class_name.split('_')])

    if confidence < 0.88:
        model_name = "gemini-1.5-flash"
        gemini_result = get_gemini_prediction(model_name, image)
        
        english_name_match = re.search(r'English:\s*([^,]+)', gemini_result)
        english_name = english_name_match.group(1).strip() if english_name_match else None
        
        if english_name:
            nutrition_info_gemini = get_nutrition_info(english_name)
            
            # Lấy lượng calo và đơn vị đo lường
            calories = nutrition_info_gemini.get("nf_calories", "N/A")
            serving_weight = next((item["serving_weight"] for item in nutrition_info_gemini.get("alt_measures", []) if item["measure"] == "g" and item["qty"] == 100), "N/A")

            return jsonify({
                'prediction': 'Gemini model used due to low confidence',
                'english_name': english_name,
                'gemini-1.5-flash': gemini_result,
                'nutrition_info': nutrition_info_gemini,
                'calories': calories,
                'serving_weight': serving_weight,
                'food_name_match': find_closest_food_name(english_name, nutrition_info_gemini["food_name"]),
            })
        else:
            return jsonify({
                'prediction': 'Gemini model used due to low confidence',
                'gemini-1.5-flash': gemini_result,
                'error': 'Could not extract English name for nutrition lookup'
            })
    
    nutrition_info_model = get_nutrition_info(food_name)

    # Lấy lượng calo và đơn vị đo lường
    calories = nutrition_info_model.get("nf_calories", "N/A")
    serving_weight = next((item["serving_weight"] for item in nutrition_info_model.get("alt_measures", []) if item["measure"] == "g" and item["qty"] == 100), "N/A")

    return jsonify({
        'predictions_model': {
            'class': class_name,
            'score': top_prediction['score'],
            'name': food_name,
            'nutrition_info': nutrition_info_model,
            'calories': calories,
            'serving_weight': serving_weight,
            'food_name_match': find_closest_food_name(food_name, nutrition_info_model["food_name"]),
        }
    })
