# import requests

# url = "http://127.0.0.1:5001/predict"

# # Hủ tiếu
# image_path = "images/image1.jpg"
# description = "Đây là 1 tô hủ tiếu có 1 con tôm, 1 quả trứng, bò viên, hủ tiếu, vài lát thịt heo mỏng và nước dùng"

# # Cơm tấm v1
# # image_path = "images/image6.png"
# # description = "Đây là dĩa cơm tấm có một lát sườn heo nướng, một trứng ốp-la, vài miếng dưa leo, nửa trái cà chua và một ít mỡ hành và dưa chua"

# # Cơm tấm v2
# # image_path = "images/image11.png"
# # description = "Đây là dĩa cơm tấm có một lát thịt heo nướng, 2 miếng dưa leo, 2 miếng cà chua và một ít mỡ hành và dưa chua"

# # Mở ảnh và gửi request
# with open(image_path, "rb") as image_file:
#     response = requests.post(url, 
#                              files={"image": image_file}, 
#                              data={"description": description})

# if response.status_code == 200:
#     print("Predictions:", response.json())
# else:
#     print("Error:", response.status_code, response.text)

import requests
import json

url = "http://127.0.0.1:5001/predict"

# Thông tin hình ảnh và mô tả món ăn
image_path = "images/image1.jpg"
description = "Đây là 1 tô hủ tiếu có 1 con tôm, 1 quả trứng, bò viên, hủ tiếu, vài lát thịt heo mỏng và nước dùng"

# Cung cấp thông tin huyết áp và đường huyết (các giá trị mẫu)
blood_pressure = {'systolic': 150, 'diastolic': 95}  # Huyết áp cao
blood_sugar = 200  # Đường huyết cao

# Mở ảnh và gửi request
with open(image_path, "rb") as image_file:
    response = requests.post(url, 
                             files={"image": image_file}, 
                             data={
                                 "description": description,
                                 "blood_pressure": json.dumps(blood_pressure),  # Chuyển đổi dictionary thành chuỗi JSON
                                 "blood_sugar": blood_sugar  # Thêm đường huyết vào request
                             })

if response.status_code == 200:
    print("Predictions:", response.json())
else:
    print("Error:", response.status_code, response.text)

