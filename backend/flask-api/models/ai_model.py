from tensorflow.keras.models import load_model
from config import MODEL_PATH, CLASSES

# Load model
model = load_model(MODEL_PATH)

def predict_with_model(image):
    predictions = model.predict(image)[0]
    top_indices = predictions.argsort()[-3:][::-1]
    top_classes = [CLASSES[i] for i in top_indices]
    top_scores = [float(predictions[i]) for i in top_indices]
    confidence = max(top_scores)

    result = [
        {"class": top_classes[i], "score": top_scores[i]}
        for i in range(len(top_classes))
    ]
    return result, confidence
