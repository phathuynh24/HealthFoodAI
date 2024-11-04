from flask import Blueprint, request, jsonify
from models.ai_model import predict_with_model
from models.gemini_model import get_gemini_prediction
from utils.image_utils import prepare_image

main = Blueprint('main', __name__)

@main.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    image = request.files['image']
    prepared_image = prepare_image(image)

    # Use the AI model to make a prediction
    model_result, confidence = predict_with_model(prepared_image)

    # Use the Gemini model if the confidence
    # if confidence < 0.9:
    model_name1 = "gemini-1.5-flash"
    model_name2 = "gemini-1.5-flash-8b"
    model_name3 = "gemini-1.5-pro"
    gemini_result1 = get_gemini_prediction(model_name1, image)
    # gemini_result2 = get_gemini_prediction(model_name2, image)
    gemini_result3 = get_gemini_prediction(model_name3, image)
        # return jsonify({
        #     'prediction': 'Gemini model used due to low confidence',
        #     'gemini-1.5-flash': gemini_result1,
        #     'gemini-1.5-flash-8b': gemini_result2,
        #     'gemini-1.5-pro': gemini_result3
        # })

    return jsonify({
        'predictions_model': model_result, 
        'predictions_gemini-1.5-flash': gemini_result1,
        # 'predictions_gemini-1.5-flash-8b': gemini_result2,
        'predictions_gemini-1.5-pro': gemini_result3
    })
