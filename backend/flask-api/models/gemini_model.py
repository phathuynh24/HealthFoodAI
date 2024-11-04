import google.generativeai as genai
from PIL import Image
from config import GEMINI_API_KEY

genai.configure(api_key=GEMINI_API_KEY)

def get_gemini_prediction(model_name, image):
    img = Image.open(image)
    prompt = "Please provide the name of the dish shown in this image with format: <dish name>"
    model = genai.GenerativeModel(model_name)
    response = model.generate_content([prompt, img])

    return response.text if response.text else "No prediction available"
