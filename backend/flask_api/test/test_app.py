import requests
import json

url = "http://127.0.0.1:5001/predict"

# Thông tin hình ảnh và mô tả món ăn

# Hủ tiếu
image_path = "images/image1.jpg"
description = "Đây là 1 tô hủ tiếu có 1 con tôm, 1 quả trứng, bò viên, hủ tiếu, vài lát thịt heo mỏng và nước dùng"

# Phở
# image_path = "images/image9.png"
# description = None

# Mô tả bằng văn bản món ăn sáng gồm bánh mì, trứng, xúc xích, cà chua, dưa chuột bằng tiếng Anh
# image_path = None
# description = "This is a breakfast meal consisting of bread, eggs, sausages, tomatoes, cucumbers"

# Cung cấp thông tin huyết áp và đường huyết (các giá trị mẫu)
blood_pressure = {'systolic': 150, 'diastolic': 90} 
blood_sugar = 90 

# Nếu có ảnh, mở và gửi ảnh cùng với mô tả, nếu không thì chỉ gửi mô tả
if image_path:
    with open(image_path, "rb") as image_file:
        response = requests.post(url, 
                                 files={"image": image_file}, 
                                 data={
                                     "description": description,
                                     "blood_pressure": json.dumps(blood_pressure),  # Chuyển đổi dictionary thành chuỗi JSON
                                     "blood_sugar": blood_sugar  # Thêm đường huyết vào request
                                 })
else:
    # Nếu không có ảnh, chỉ gửi mô tả và các thông tin khác
    response = requests.post(url, 
                             data={
                                 "description": description,
                                 "blood_pressure": json.dumps(blood_pressure),
                                 "blood_sugar": blood_sugar
                             })

if response.status_code == 200:
    print("Predictions:", response.json())
else:
    print("Error:", response.status_code, response.text)

