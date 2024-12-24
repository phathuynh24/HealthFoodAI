from flask import Blueprint, request, jsonify
import requests
import logging

recommendation = Blueprint('recommendation', __name__)

# API Key
SPOONACULAR_API_KEY = '60d38f22a699426986793ae315c8be0e'

if not SPOONACULAR_API_KEY:
    logging.error("SPOONACULAR_API_KEY not found.")
    raise ValueError("SPOONACULAR_API_KEY not found.")

logging.basicConfig(level=logging.INFO)

@recommendation.route('/recommendation/suggest-recipes', methods=['POST'])
def suggest_recipes():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    user_id = data.get('userId')
    preferences = data.get('preferences')
    nutrition = data.get('nutrition')

    if not user_id or not preferences or not nutrition:
        return jsonify({"error": "userId, preferences, and nutrition are required"}), 400

    logging.info(f"Request received from user {user_id}: {preferences}, {nutrition}")

    if 'calories' not in nutrition or 'protein' not in nutrition:
        return jsonify({"error": "Nutrition details (calories, protein, etc.) are required"}), 400

    cuisine = preferences.get('cuisine', 'any')
    spicy = preferences.get('spicy', False)
    sweet = preferences.get('sweet', False)

    target_factors = calculate_target_factors(nutrition)
    max_calories = int(3000 * target_factors.get('calories', 1.0))
    max_sodium = int(5000 * target_factors.get('salt', 1.0))
    max_fat = int(70 * target_factors.get('fat', 1.0))

    recipes = get_recipe_suggestions(
        api_key=SPOONACULAR_API_KEY,
        max_calories=max_calories,
        max_sodium=max_sodium,
        cuisine=cuisine,
        spicy=spicy,
        sweet=sweet,
        number=5
    )

    # filtered_recipes = filter_recipes(recipes, max_fat)

    # if not filtered_recipes:
    #     return jsonify({"error": "No recipes found for the given criteria."}), 404

    # return jsonify({"recipes": filtered_recipes[:5]}), 200

    if not recipes:
        return jsonify({"error": "No recipes found for the given criteria."}), 404

    return jsonify({"recipes": recipes}), 200


def calculate_target_factors(avg_nutrition):
    recommended = {
        'calories': 3000,
        'salt': 5,
        'fat': 70,
        'protein': 50,
        'carbs': 310
    }
    target_factors = {}
    for key, value in recommended.items():
        if avg_nutrition.get(key, 0) > value:
            ratio = avg_nutrition[key] / value
            target_factors[key] = max(0.7, 1 - (ratio - 1))
        else:
            target_factors[key] = 1.0
    return target_factors


def get_recipe_suggestions(api_key, max_calories, max_sodium, cuisine, spicy, sweet, number=10):
    url = "https://api.spoonacular.com/recipes/complexSearch"
    params = {
        "apiKey": api_key,
        "maxCalories": max_calories,
        "number": number,
        "addRecipeInformation": True,
        "fillIngredients": True,
    }

    include_ingredients = []
    if spicy:
        include_ingredients.append("chili")
    if sweet:
        include_ingredients.append("sugar")

    if include_ingredients:
        params["includeIngredients"] = ",".join(include_ingredients)

    try:
        logging.info(f"Calling Spoonacular API with params: {params}")
        response = requests.get(url, params=params)
        response.raise_for_status()
        return response.json().get('results', [])
    except requests.RequestException as e:
        logging.error(f"Error calling Spoonacular API: {e}")
        return []


def filter_recipes(recipes, max_fat):
    filtered = []
    for recipe in recipes:
        nutrients = recipe.get('nutrition', {}).get('nutrients', [])
        fat = next((n['amount'] for n in nutrients if n['name'] == 'Fat'), None)
        if fat is not None and fat <= max_fat:
            filtered.append(recipe)
    return filtered
