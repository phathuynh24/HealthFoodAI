# gemini_model.py
import google.generativeai as genai
from PIL import Image
from config import GEMINI_API_KEY

# Cấu hình API key cho Gemini
genai.configure(api_key=GEMINI_API_KEY)

def get_gemini_prediction(model_name, image, description=None):
    # Mở ảnh
    img = Image.open(image)
    
    # Tạo prompt cơ bản và bổ sung mô tả từ người dùng
    prompt = (
        "This is a food image. Please analyze and provide a detailed response with the following format:\n"
        "Vietnamese: <food_name_vi>,\n"
        "English: <food_name_en>,\n"
        "Ingredients: <ingredient_1> (~<weight_in_grams>), <ingredient_2> (~<weight_in_grams>),...\n"
        "Please ensure all ingredient weights are in grams (g) format."
    )
    
    # Nếu có mô tả của người dùng, bổ sung vào prompt
    if description:
        prompt += f"\nUser description: {description}\nPlease use this description to improve accuracy."

    # Tạo model và gửi prompt
    model = genai.GenerativeModel(model_name)
    response = model.generate_content([prompt, img])

    # Kiểm tra và trả về kết quả
    return response.text if response and response.text else "No prediction available"
