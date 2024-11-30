import os
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
MODEL_PATH = os.getenv("MODEL_PATH")

# Define the 101 classes for Food-101 dataset with Vietnamese names
CLASSES = {
    'apple_pie': 'Bánh táo',
    'baby_back_ribs': 'Sườn cừu',
    'baklava': 'Bánh baklava',
    'beef_carpaccio': 'Thịt bò carpaccio',
    'beef_tartare': 'Thịt bò tươi',
    'beet_salad': 'Salad củ cải',
    'beignets': 'Bánh beignet',
    'bibimbap': 'Bibimbap',
    'bread_pudding': 'Pudding bánh mì',
    'breakfast_burrito': 'Burrito bữa sáng',
    'bruschetta': 'Bánh mì bruschetta',
    'caesar_salad': 'Salad Caesar',
    'cannoli': 'Cannoli',
    'caprese_salad': 'Salad Caprese',
    'carrot_cake': 'Bánh cà rốt',
    'ceviche': 'Ceviche',
    'cheese_plate': 'Đĩa phô mai',
    'cheesecake': 'Bánh phô mai',
    'chicken_curry': 'Cà ri gà',
    'chicken_quesadilla': 'Quesadilla gà',
    'chicken_wings': 'Cánh gà',
    'chocolate_cake': 'Bánh socola',
    'chocolate_mousse': 'Mousse socola',
    'churros': 'Churros',
    'clam_chowder': 'Súp ngao',
    'club_sandwich': 'Sandwich câu lạc bộ',
    'crab_cakes': 'Bánh cua',
    'creme_brulee': 'Crème brûlée',
    'croque_madame': 'Croque madame',
    'cup_cakes': 'Bánh cupcake',
    'deviled_eggs': 'Trứng ác quỷ',
    'donuts': 'Bánh donuts',
    'dumplings': 'Món há cảo',
    'edamame': 'Đậu edamame',
    'eggs_benedict': 'Trứng Benedict',
    'escargots': 'Ốc sên',
    'falafel': 'Falafel',
    'filet_mignon': 'Thịt thăn',
    'fish_and_chips': 'Cá và khoai tây chiên',
    'foie_gras': 'Gan ngỗng',
    'french_fries': 'Khoai tây chiên',
    'french_onion_soup': 'Súp hành tây Pháp',
    'french_toast': 'Bánh mì nướng Pháp',
    'fried_calamari': 'Mực chiên',
    'fried_rice': 'Cơm chiên',
    'frozen_yogurt': 'Sữa chua đông lạnh',
    'garlic_bread': 'Bánh mì tỏi',
    'gnocchi': 'Mì gnocchi',
    'greek_salad': 'Salad Hy Lạp',
    'grilled_cheese_sandwich': 'Sandwich phô mai nướng',
    'grilled_salmon': 'Cá hồi nướng',
    'guacamole': 'Guacamole',
    'gyoza': 'Món bánh bao Nhật',
    'hamburger': 'Hamburger',
    'hot_and_sour_soup': 'Súp cay chua',
    'hot_dog': 'Hotdog',
    'huevos_rancheros': 'Huevos Rancheros',
    'hummus': 'Hummus',
    'ice_cream': 'Kem',
    'lasagna': 'Lasagna',
    'lobster_bisque': 'Súp tôm hùm',
    'lobster_roll_sandwich': 'Bánh sandwich tôm hùm',
    'macaroni_and_cheese': 'Mì macaroni và phô mai',
    'macarons': 'Macaron',
    'miso_soup': 'Súp miso',
    'mussels': 'Con hàu',
    'nachos': 'Nachos',
    'omelette': 'Trứng tráng',
    'onion_rings': 'Nhẫn hành',
    'oysters': 'Hàu',
    'pad_thai': 'Phở Thái',
    'paella': 'Paella',
    'pancakes': 'Bánh pancake',
    'panna_cotta': 'Panna cotta',
    'peking_duck': 'Vịt quay Bắc Kinh',
    'pho': 'Phở',
    'pizza': 'Pizza',
    'pork_chop': 'Sườn heo',
    'poutine': 'Poutine',
    'prime_rib': 'Thịt rib nướng',
    'pulled_pork_sandwich': 'Sandwich thịt heo xé',
    'ramen': 'Mì ramen',
    'ravioli': 'Mì ravioli',
    'red_velvet_cake': 'Bánh Red Velvet',
    'risotto': 'Risotto',
    'samosa': 'Samosa',
    'sashimi': 'Sashimi',
    'scallops': 'Sò điệp',
    'seaweed_salad': 'Salad rong biển',
    'shrimp_and_grits': 'Tôm và bột ngô',
    'spaghetti_bolognese': 'Mì spaghetti sốt Bolognese',
    'spaghetti_carbonara': 'Mì spaghetti sốt Carbonara',
    'spring_rolls': 'Chả giò',
    'steak': 'Steak',
    'strawberry_shortcake': 'Bánh dâu tây',
    'sushi': 'Sushi',
    'tacos': 'Tacos',
    'takoyaki': 'Takoyaki',
    'tiramisu': 'Tiramisu',
    'tuna_tartare': 'Tartare cá ngừ',
    'waffles': 'Bánh quế'
}
