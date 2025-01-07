import requests

# URL của API Flask
url = "http://10.0.136.33:5001/translate"

# Dữ liệu văn bản cần dịch
payload = {
    "text": "This is a test to see how the translation API works."
}

try:
    # Gửi yêu cầu POST tới API
    response = requests.post(url, json=payload)

    # Kiểm tra mã trạng thái phản hồi
    if response.status_code == 200:
        # In nội dung phản hồi
        print("Phản hồi từ API:", response.json())
    else:
        print(f"Lỗi API: Mã trạng thái {response.status_code}")
        print("Chi tiết lỗi:", response.text)

except Exception as e:
    print("Đã xảy ra lỗi khi gửi yêu cầu:", str(e))
