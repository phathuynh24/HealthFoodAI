import google.generativeai as genai
from PIL import Image
from config import GEMINI_API_KEY

genai.configure(api_key=GEMINI_API_KEY)

def get_gemini_prediction(model_name, image):
    img = Image.open(image)
    prompt = "What is this food? Please respond in the following format: Vietnamese: <food_name_vi>, English: <food_name_en>, Ingredients: <ingredient_1> (~<weight_in_grams>), <ingredient_2> (<weight_in_grams>g, ~<calories> kcal),... Total calories: <total_calories> kcal."
    model = genai.GenerativeModel(model_name)
    response = model.generate_content([prompt, img])

    return response.text if response.text else "No prediction available"
