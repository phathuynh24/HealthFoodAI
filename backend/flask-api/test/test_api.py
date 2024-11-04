import requests

url = "http://127.0.0.1:5001/predict"

# gemini-1.5-flash-8b': '<Bún riêu> => failed
# image_path = "images/image1.jpg" Hủ tiếu Nam Vang

# 'predictions_gemini-1.5-flash': 'Com Tam Suon Cha' => very good prediction
# 'predictions_gemini-1.5-flash-8b': '<Com Tam>' => failed
# 'predictions_gemini-1.5-pro': 'Cơm tấm sườn nướng' => good prediction 
# image_path = "images/image6.png"

# 'predictions_gemini-1.5-flash': 'Grilled Fish with Lemon Sauce and Vegetables' => very good prediction
# 'predictions_gemini-1.5-pro': 'Grilled fish with vegetables' => good prediction
# 'predictions_model': [{'class': 'scallops', 'score': 0.8646203279495239}, 
#                       {'class': 'fried_rice', 'score': 0.06544137746095657}, 
#                       {'class': 'caesar_salad', 'score': 0.011448504403233528}]}
image_path = "images/image8.png"

with open(image_path, "rb") as image_file:
    response = requests.post(url, files={"image": image_file})

if response.status_code == 200:
    print("Predictions:", response.json())
else:
    print("Error:", response.status_code, response.text)
