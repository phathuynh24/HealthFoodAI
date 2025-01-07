from flask import Blueprint, request, jsonify
import google.generativeai as genai
from config import GEMINI_API_KEY

translate = Blueprint('translate', __name__)

# Configure API key for Gemini
genai.configure(api_key=GEMINI_API_KEY)

@translate.route('/translate', methods=['POST'])
def gemini_translate():
    try:
        # Get the input data
        data = request.json
        if not data or 'texts' not in data:
            return jsonify({"error": "Missing 'texts' in request body"}), 400

        texts_to_translate = data['texts']

        if not isinstance(texts_to_translate, list) or not all(isinstance(text, str) for text in texts_to_translate):
            return jsonify({"error": "'texts' must be a list of strings"}), 400

        # Generate the translated content for each text
        translated_texts = []
        for text in texts_to_translate:
            prompt = f"Dịch văn bản sau sang tiếng Việt: {text}"
            model = genai.GenerativeModel("gemini-1.5-flash")
            response = model.generate_content([prompt])
            translated_texts.append(response.text.strip())

        return jsonify({"translated_texts": translated_texts})

    except Exception as e:
        return jsonify({"error": str(e)}), 500
