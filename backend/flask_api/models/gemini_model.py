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
            "Total Ingredients: <food_item_1>|<food_item_1_vi> (~<total_weight_in_grams>), <food_item_2>|<food_item_2_vi> (~<total_weight_in_grams>),...\n"
            "Example: Apple|Táo (~100g), Hamburger|Bánh mì Hamburger (~200g), Orange Juice|Nước cam (~240g)\n"
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
            "Ingredients: <ingredient_1>|<ingredient_1_vi> (~<weight_in_grams>), <ingredient_2>|<ingredient_2_vi> (~<weight_in_grams>), ...\n"
            "Limit the analysis to a maximum of the top 7 main ingredients only, based on their significance in the dish "
            "(e.g., key protein sources, starches, or key vegetables). Exclude minor garnishes or decorations (e.g., herbs, "
            "small garnishes, or condiments) unless they are essential to the dish.\n"
            "Example: Pork|Thịt heo (~150g), Rice|Cơm (~200g), Egg|Trứng (~50g), Cucumber|Dưa leo (~50g), Tomato|Cà chua (~50g)\n"
            "Please ensure all ingredient weights are in grams (g) format. Focus on the core elements that define the dish, "
            "and avoid listing very minor ingredients unless they significantly impact the dish.\n"
            "Please make sure the ingredient list is concise and includes only the most relevant items."
        )
        if description:
            prompt += f"\nUser description: {description}\nPlease use this description to improve accuracy."
        
        # Create model and send both the prompt and image
        model = genai.GenerativeModel(model_name)
        response = model.generate_content([prompt, img])

    # Check and return the result
    return response.text if response and response.text else "No prediction available"
