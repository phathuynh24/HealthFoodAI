from tensorflow.keras.models import load_model
from config import MODEL_PATH, CLASSES

# Load model
model = load_model(MODEL_PATH)

def predict_with_model(image):
    predictions = model.predict(image)[0]
    top_indices = predictions.argsort()[-3:][::-1]  # Top 3 dự đoán

    # Lấy tên món ăn tiếng Anh từ các chỉ số top_indices
    top_classes = [list(CLASSES.keys())[i] for i in top_indices]
    
    # Lấy tên món ăn tiếng Việt từ CLASSES (tên tiếng Anh sẽ là khóa, tên tiếng Việt là giá trị)
    top_classes_vi = [CLASSES.get(class_name) for class_name in top_classes]

    # Lấy điểm số cho từng món ăn
    top_scores = [float(predictions[i]) for i in top_indices]
    
    # Lấy xác suất cao nhất (confidence)
    confidence = max(top_scores)

    # Kết quả trả về dưới dạng danh sách các từ điển
    result = [
        {"class": top_classes[i], "class_vi": top_classes_vi[i], "score": top_scores[i]}
        for i in range(len(top_classes))
    ]
    
    return result, confidence