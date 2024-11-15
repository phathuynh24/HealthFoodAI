# # gemini_model.py
# import google.generativeai as genai
# from PIL import Image
# from config import GEMINI_API_KEY

# # Cấu hình API key cho Gemini
# genai.configure(api_key=GEMINI_API_KEY)

# def get_gemini_prediction(model_name, image=None, description=None):
#     # Mở ảnh
#     img = Image.open(image)
    
#     # Tạo prompt cơ bản và bổ sung mô tả từ người dùng
#     prompt = (
#         "This is a food image. Please analyze and provide a detailed response with the following format:\n"
#         "Vietnamese: <food_name_vi>,\n"
#         "English: <food_name_en>,\n"
#         "Ingredients: <ingredient_1> (~<weight_in_grams>), <ingredient_2> (~<weight_in_grams>),...\n"
#         "Please ensure all ingredient weights are in grams (g) format."
#     )
    
#     # Nếu có mô tả của người dùng, bổ sung vào prompt
#     if description:
#         prompt += f"\nUser description: {description}\nPlease use this description to improve accuracy."

#     # Tạo model và gửi prompt
#     model = genai.GenerativeModel(model_name)
#     response = model.generate_content([prompt, img])

#     # Kiểm tra và trả về kết quả
#     return response.text if response and response.text else "No prediction available"


import google.generativeai as genai
from PIL import Image
from config import GEMINI_API_KEY

# Configure API key for Gemini
genai.configure(api_key=GEMINI_API_KEY)

def get_gemini_prediction(model_name, image=None, description=None):
    if description and not image:
        # Text-only prompt
        prompt = (
            "The following is a user-provided description of food items. Please analyze and list each item, "
            "along with an estimated weight in grams. Use the following format:\n"
            "Food Names: <food_item_1>, <food_item_2>,...\n"
            "Total Ingredients: <food_item_1> (~<total_weight_in_grams>), <food_item_2> (~<total_weight_in_grams>),...\n"
            "Example: Apple (~100g), Hamburger (~200g), Orange Juice (~240g)\n"
            "Ensure weights are in grams (g) format, showing only the total weight per item, with no additional comments or annotations."
            f"\nUser description: {description}"
        )
        # Create model and send only the prompt for text-based processing
        model = genai.GenerativeModel(model_name)
        response = model.generate_content([prompt])

    else:
        # Open and include the image in the prompt for image-based processing
        img = Image.open(image)
        prompt = (
            "This is a food image. Please analyze and provide a detailed response with the following format:\n"
            "Vietnamese: <food_name_vi>,\n"
            "English: <food_name_en>,\n"
            "Ingredients: <ingredient_1> (~<weight_in_grams>), <ingredient_2> (~<weight_in_grams>),...\n"
            "Limit the analysis to a maximum of the top 5 main ingredients only.\n"
            "Example: Pork (~100g), Beef (~150g), Carrots (~50g)\n"
            "Please ensure all ingredient weights are in grams (g) format."
        )
        if description:
            prompt += f"\nUser description: {description}\nPlease use this description to improve accuracy."
        
        # Create model and send both the prompt and image
        model = genai.GenerativeModel(model_name)
        response = model.generate_content([prompt, img])

    # Check and return the result
    return response.text if response and response.text else "No prediction available"
