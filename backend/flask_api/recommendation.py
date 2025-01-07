from flask import Blueprint, request, jsonify
import requests
import logging
import random
import google.generativeai as genai
from config import SPOONACULAR_API_KEY, GEMINI_API_KEY

recommendation = Blueprint('recommendation', __name__)

# Configure API key for Gemini
genai.configure(api_key=GEMINI_API_KEY)

logging.basicConfig(level=logging.INFO)

# @recommendation.route('/recommendation/suggest-recipes', methods=['POST'])
# def suggest_and_translate_recipes():
#     try:
#         # Get the input data
#         data = request.get_json()
#         if not data:
#             return jsonify({"error": "No data provided"}), 400

#         user_id = data.get('userId')
#         preferences = data.get('preferences', {})
#         nutrition = data.get('nutrition', {})

#         if not user_id or not preferences or not nutrition:
#             return jsonify({"error": "userId, preferences, and nutrition are required"}), 400

#         # Mapping FE preferences to Spoonacular API parameters
#         cuisine = preferences.get('cuisine', '')
#         include_ingredients = []
#         exclude_ingredients = []

#         # Các thành phần cố định cho từng hương vị
#         sweet_ingredients = ["sugar", "cane sugar", "honey"]
#         salty_ingredients = ["sea salt", "salt", "soy sauce"]
#         sour_ingredients = ["vinegar", "lemon", "lime"]
#         bitter_ingredients = ["dark chocolate", "coffee", "arugula"]
#         savory_ingredients = ["umami", "anchovies", "soy sauce"]
#         fatty_ingredients = ["butter", "olive oil", "cream"]

#         if preferences.get('sweet', False):
#             include_ingredients.append(random.choice(sweet_ingredients))  # Chọn ngẫu nhiên một thành phần từ sweet_ingredients
#         if preferences.get('salty', False):
#             include_ingredients.append(random.choice(salty_ingredients))  # Chọn ngẫu nhiên một thành phần từ salty_ingredients
#         if preferences.get('sour', False):
#             include_ingredients.append(random.choice(sour_ingredients))  # Chọn ngẫu nhiên một thành phần từ sour_ingredients
#         if preferences.get('bitter', False):
#             include_ingredients.append(random.choice(bitter_ingredients))  # Chọn ngẫu nhiên một thành phần từ bitter_ingredients
#         if preferences.get('savory', False):
#             include_ingredients.append(random.choice(savory_ingredients))  # Chọn ngẫu nhiên một thành phần từ savory_ingredients
#         if preferences.get('fatty', False):
#             include_ingredients.append(random.choice(fatty_ingredients))  # Chọn ngẫu nhiên một thành phần từ fatty_ingredients

#         # Loại bỏ trùng lặp trong danh sách
#         include_ingredients = list(set(include_ingredients))

#         # Adjust nutritional limits based on user input
#         max_calories = nutrition.get('calories', 2000)
#         max_fat = nutrition.get('fat', 70)
#         max_protein = nutrition.get('protein', 50)
#         max_carbs = nutrition.get('carbs', 310)

#         # Call Spoonacular API
#         recipes = get_recipe_suggestions(
#             api_key=SPOONACULAR_API_KEY,
#             max_calories=max_calories,
#             max_fat=max_fat,
#             max_protein=max_protein,
#             max_carbs=max_carbs,
#             cuisine=cuisine,
#             include_ingredients=include_ingredients,
#             exclude_ingredients=exclude_ingredients,
#             number=3
#         )

#         if not recipes:
#             return jsonify({"error": "No recipes found for the given criteria."}), 404

#         for recipe in recipes:
#             try:
#                 # Translate title
#                 title = recipe.get('title', 'Không có tiêu đề')
#                 title_prompt = f"Dịch văn bản sau sang tiếng Việt (chỉ cho duy nhất 1 kết quả): {title}"
#                 title_response = genai.GenerativeModel("gemini-1.5-flash").generate_content([title_prompt])
#                 recipe['title_translated'] = title_response.text.strip() if title_response and hasattr(title_response, 'text') else title
#             except Exception as e:
#                 logging.error(f"Error translating title for recipe {recipe.get('id', 'unknown')}: {e}")
#                 recipe['title_translated'] = title

#             # Translate ingredients
#             # recipe["extendedIngredients"] = process_and_translate_ingredients(recipe.get("extendedIngredients", []))

#         return jsonify({"recipes": recipes})

#     except Exception as e:
#         logging.error(f"Error in suggest_and_translate_recipes: {e}")
#         return jsonify({"error": str(e)}), 500

@recommendation.route('/recommendation/suggest-recipes', methods=['POST'])
def suggest_and_translate_recipes():
    try:
        # Get the input data
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400

        user_id = data.get('userId')
        preferences = data.get('preferences', {})
        nutrition = data.get('nutrition', {})

        if not user_id or not preferences or not nutrition:
            return jsonify({"error": "userId, preferences, and nutrition are required"}), 400

        # Mapping FE preferences to Spoonacular API parameters
        cuisine = preferences.get('cuisine', '')
        include_ingredients = []
        exclude_ingredients = []

        # Các thành phần cố định cho từng hương vị
        sweet_ingredients = ["sugar", "cane sugar", "honey"]
        salty_ingredients = ["sea salt", "salt", "soy sauce"]
        sour_ingredients = ["vinegar", "lemon", "lime"]
        bitter_ingredients = ["dark chocolate", "coffee", "arugula"]
        savory_ingredients = ["umami", "anchovies", "soy sauce"]
        fatty_ingredients = ["butter", "olive oil", "cream"]

        if preferences.get('sweet', False):
            include_ingredients.append(random.choice(sweet_ingredients))
        if preferences.get('salty', False):
            include_ingredients.append(random.choice(salty_ingredients))
        if preferences.get('sour', False):
            include_ingredients.append(random.choice(sour_ingredients))
        if preferences.get('bitter', False):
            include_ingredients.append(random.choice(bitter_ingredients))
        if preferences.get('savory', False):
            include_ingredients.append(random.choice(savory_ingredients))
        if preferences.get('fatty', False):
            include_ingredients.append(random.choice(fatty_ingredients))

        # Loại bỏ trùng lặp trong danh sách
        include_ingredients = list(set(include_ingredients))

        # Adjust nutritional limits based on user input
        max_calories = nutrition.get('calories', 2000)
        max_fat = nutrition.get('fat', 70)
        max_protein = nutrition.get('protein', 50)
        max_carbs = nutrition.get('carbs', 310)

        # Call Spoonacular API to get recipe suggestions
        recipes = get_recipe_suggestions(
            api_key=SPOONACULAR_API_KEY,
            max_calories=max_calories,
            max_fat=max_fat,
            max_protein=max_protein,
            max_carbs=max_carbs,
            cuisine=cuisine,
            include_ingredients=include_ingredients,
            exclude_ingredients=exclude_ingredients,
            number=3
        )

        if not recipes:
            return jsonify({"error": "No recipes found for the given criteria."}), 404

        # For each recipe, call the detailed information API to get the introduction
        for recipe in recipes:
            try:
                recipe_id = recipe.get('id')
                if recipe_id:
                    # Get detailed recipe information (including introduction and steps)
                    recipe_info = get_recipe_instructions(recipe_id)
                    recipe['introduce'] = recipe_info  # Store all the information from the response into 'introduce'

                # Translate title (you already have this code)
                title = recipe.get('title', 'Không có tiêu đề')
                title_prompt = f"Dịch văn bản sau sang tiếng Việt (chỉ cho duy nhất 1 kết quả): {title}"
                title_response = genai.GenerativeModel("gemini-1.5-flash").generate_content([title_prompt])
                recipe['title_translated'] = title_response.text.strip() if title_response and hasattr(title_response, 'text') else title

                # Translate ingredients
                recipe["extendedIngredients"] = process_and_translate_ingredients(recipe.get("extendedIngredients", []))

                # Translate steps
                recipe["introduce"] = process_and_translate_introduce(recipe.get("introduce", []))

            except Exception as e:
                logging.error(f"Error processing recipe {recipe.get('id', 'unknown')}: {e}")

        return jsonify({"recipes": recipes})

    except Exception as e:
        logging.error(f"Error in suggest_and_translate_recipes: {e}")
        return jsonify({"error": str(e)}), 500

def get_recipe_instructions(recipe_id):
    """
    Gọi API Spoonacular để lấy thông tin chi tiết của công thức (bao gồm tất cả thông tin từ analyzedInstructions)
    """
    url = f"https://api.spoonacular.com/recipes/{recipe_id}/analyzedInstructions"
    params = {
        "apiKey": SPOONACULAR_API_KEY,
    }

    try:
        logging.info(f"Calling Spoonacular API for recipe {recipe_id} details.")
        response = requests.get(url, params=params)
        response.raise_for_status()

        # Lấy toàn bộ thông tin trả về từ API và lưu vào 'introduce'
        recipe_info = response.json()  # Lưu tất cả response vào 'introduce'
        
        return recipe_info
    except requests.RequestException as e:
        logging.error(f"Error calling Spoonacular API for recipe {recipe_id}: {e}")
        return {}

def get_recipe_suggestions(api_key, max_calories, max_fat, max_protein, max_carbs,
                           cuisine, include_ingredients, exclude_ingredients, number=10):
    url = "https://api.spoonacular.com/recipes/complexSearch"
    params = {
        "apiKey": api_key,
        "cuisine": cuisine,
        "maxCalories": max_calories,
        "maxFat": max_fat,
        "maxProtein": max_protein,
        "maxCarbs": max_carbs,
        "number": number,
        "addRecipeInformation": True,
        "fillIngredients": True,
    }

    if include_ingredients:
        params["includeIngredients"] = ",".join(include_ingredients)
    if exclude_ingredients:
        params["excludeIngredients"] = ",".join(exclude_ingredients)

    try:
        logging.info(f"Calling Spoonacular API with params: {params}")
        response = requests.get(url, params=params)
        response.raise_for_status()
        return response.json().get('results', [])
    except requests.RequestException as e:
        logging.error(f"Error calling Spoonacular API: {e}")
        return []

def process_and_translate_ingredients(ingredients, model_name="gemini-1.5-flash"):
    """
    Hàm xử lý danh sách nguyên liệu và dịch toàn bộ trong một lần API call.
    """
    try:
        if not ingredients:
            return []

        # Tạo một chuỗi chứa danh sách các nguyên liệu
        ingredients_text = "\n".join([f"{idx + 1}. {ingredient.get('original', '')}" for idx, ingredient in enumerate(ingredients)])

        # Tạo prompt để dịch chuỗi
        prompt = f"Dịch danh sách nguyên liệu sau sang tiếng Việt:\n{ingredients_text}"
        model = genai.GenerativeModel(model_name)
        response = model.generate_content([prompt])

        # Phân tách bản dịch thành danh sách
        translated_lines = response.text.strip().split("\n")
        
        # Gắn lại bản dịch vào object nguyên liệu
        for ingredient, translated_line in zip(ingredients, translated_lines):
            ingredient["translated_original"] = translated_line

        return ingredients
    except Exception as e:
        logging.error(f"Error translating ingredients: {e}")
        for ingredient in ingredients:
            ingredient["translated_original"] = "Lỗi khi dịch nguyên liệu"
        return ingredients

# def process_and_translate_introduce(introduce, model_name="gemini-1.5-flash"):
#     """
#     Hàm xử lý và dịch toàn bộ phần 'introduce' (bao gồm các bước chế biến) từ tiếng Anh sang tiếng Việt,
#     gọi Gemini API một lần duy nhất.
#     """
#     try:
#         if not introduce:
#             return []

#         # Gom tất cả các bước chế biến vào một chuỗi duy nhất
#         steps_text = ""
#         for intro in introduce:
#             steps = intro.get('steps', [])
#             for step in steps:
#                 steps_text += f"Bước {step.get('number', 'N/A')}: {step.get('step', '')}\n"

#         # Tạo prompt để dịch chuỗi các bước chế biến
#         prompt = f"Dịch danh sách các bước chế biến sau sang tiếng Việt:\n{steps_text}"
#         model = genai.GenerativeModel(model_name)
#         response = model.generate_content([prompt])

#         # Phân tách bản dịch thành danh sách các bước
#         translated_lines = response.text.strip().split("\n")

#         # Lặp lại qua tất cả các bước và gắn bản dịch vào trong từng bước
#         translated_line_index = 0
#         for intro in introduce:
#             steps = intro.get('steps', [])
#             for step in steps:
#                 if translated_line_index < len(translated_lines):
#                     step["translated_step"] = translated_lines[translated_line_index]
#                     translated_line_index += 1
#                 else:
#                     step["translated_step"] = "Lỗi khi dịch bước chế biến"

#         return introduce

#     except Exception as e:
#         logging.error(f"Error translating introduce: {e}")
#         for intro in introduce:
#             intro['steps'] = [{"translated_step": "Lỗi khi dịch bước chế biến"}]
#         return introduce

def process_and_translate_introduce(introduce, model_name="gemini-1.5-flash"):
    """
    Hàm xử lý và dịch toàn bộ phần 'introduce' (bao gồm các bước chế biến) từ tiếng Anh sang tiếng Việt,
    gọi Gemini API một lần duy nhất.
    """
    try:
        if not introduce:
            return []

        # Gom tất cả các bước chế biến vào một chuỗi duy nhất
        steps_text = ""
        for intro in introduce:
            steps = intro.get('steps', [])
            for step in steps:
                # Gom mỗi bước vào trong chuỗi theo định dạng "Bước X: Y"
                steps_text += f"Bước {step.get('number', 'N/A')}: {step.get('step', '')}\n"

        # Tạo prompt để dịch chuỗi các bước chế biến
        prompt = f"Dịch danh sách các bước chế biến sau sang tiếng Việt:\n{steps_text}"
        model = genai.GenerativeModel(model_name)
        response = model.generate_content([prompt])

        # Phân tách bản dịch thành danh sách các bước
        translated_lines = response.text.strip().split("\n")
        

        # Kiểm tra số lượng bước đã dịch và cập nhật vào từng bước
        translated_line_index = 0
        for intro in introduce:
            steps = intro.get('steps', [])
            for step in steps:
                # Nếu có bản dịch, gán bản dịch vào 'translated_step'
                if translated_line_index < len(translated_lines):
                    step["translated_step"] = translated_lines[translated_line_index]
                    translated_line_index += 1
                else:
                    # Nếu không có bản dịch, dùng 'step' gốc
                    step["translated_step"] = step['step']

        # Kiểm tra nếu còn bước nào chưa được dịch
        if translated_line_index < len(translated_lines):
            logging.warning(f"Có {len(translated_lines) - translated_line_index} bước chưa được dịch.")
        
        return introduce

    except Exception as e:
        logging.error(f"Error translating introduce: {e}")
        for intro in introduce:
            # Trả về lỗi cho tất cả các bước nếu có lỗi
            intro['steps'] = [{"translated_step": "Lỗi khi dịch bước chế biến"}]
        return introduce

