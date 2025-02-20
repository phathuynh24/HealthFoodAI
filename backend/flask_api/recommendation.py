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

@recommendation.route('/recommendation/suggest-recipes', methods=['POST'])
def suggest_and_translate_recipes():
    try:
        # Nhận dữ liệu từ FE
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400

        user_id = data.get('userId')
        preferences = data.get('preferences', {})
        nutrition = data.get('nutrition', {})

        if not user_id or not preferences or not nutrition:
            return jsonify({"error": "userId, preferences, and nutrition are required"}), 400

        # Lấy thông tin preferences
        cuisine = preferences.get('cuisine', '')
        include_ingredients = preferences.get('ingredients', [])
        exclude_ingredients = preferences.get('excludeIngredients', [])

        # Loại bỏ trùng lặp trong danh sách
        include_ingredients = list(set(include_ingredients))

        # Lấy giá trị dinh dưỡng tối thiểu và tối đa từ FE
        min_calories = nutrition.get('calories_min', 0)
        max_calories = nutrition.get('calories_max', 200)

        min_protein = nutrition.get('protein_min', 0)
        max_protein = nutrition.get('protein_max', 50)

        min_fat = nutrition.get('fat_min', 0)
        max_fat = nutrition.get('fat_max', 30)

        min_carbs = nutrition.get('carbs_min', 0)
        max_carbs = nutrition.get('carbs_max', 100)

        # Gọi Spoonacular API với các tham số dinh dưỡng mới
        recipes = get_recipe_suggestions(
            api_key=SPOONACULAR_API_KEY,
            min_calories=min_calories,
            max_calories=max_calories,
            min_protein=min_protein,
            max_protein=max_protein,
            min_fat=min_fat,
            max_fat=max_fat,
            min_carbs=min_carbs,
            max_carbs=max_carbs,
            cuisine=cuisine,
            include_ingredients=include_ingredients,
            exclude_ingredients=exclude_ingredients,
            number=2
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

def get_recipe_suggestions(api_key, 
                           min_calories, max_calories, 
                           min_fat, max_fat, 
                           min_protein, max_protein, 
                           min_carbs, max_carbs, 
                           cuisine, include_ingredients, 
                           exclude_ingredients, 
                           number=1):
    url = "https://api.spoonacular.com/recipes/complexSearch"
    params = {
        "apiKey": api_key,
        "cuisine": cuisine,
        # "minCalories": min_calories,  # Giới hạn tối thiểu
        "maxCalories": max_calories,  # Giới hạn tối đa
        # "minFat": min_fat,
        # "maxFat": max_fat,
        # "minProtein": min_protein,
        # "maxProtein": max_protein,
        # "minCarbs": min_carbs,
        # "maxCarbs": max_carbs,
        "number": number,
        "addRecipeInformation": True,
        "fillIngredients": True,
    }

    # # Xử lý thành phần cần bao gồm
    # if include_ingredients:
    #     selected_include = random.sample(include_ingredients, min(len(include_ingredients), 2))
    #     params["includeIngredients"] = ",".join(selected_include)

    # # Xử lý thành phần cần loại trừ
    # if exclude_ingredients:
    #     selected_exclude = random.sample(exclude_ingredients, min(len(exclude_ingredients), 2))
    #     params["excludeIngredients"] = ",".join(selected_exclude)

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
        translated_lines = response.text.strip().split("\n\n")
        
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

