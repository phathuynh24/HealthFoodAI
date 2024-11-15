import requests

url = "http://127.0.0.1:5001/predict"

image_path = "images/image1.jpg"
with open(image_path, "rb") as image_file:
    response = requests.post(url, files={"image": image_file})

# description = "1 apple, 2 hamburgers, 1 glass of orange juice"
# response = requests.post(url, data={"description": description})

if response.status_code == 200:
    print("Predictions:", response.json())
else:
    print("Error:", response.status_code, response.text)
