from tensorflow.keras.preprocessing.image import img_to_array
from PIL import Image
import numpy as np
import io

def prepare_image(image, target_size=(224, 224)):
    img = Image.open(io.BytesIO(image.read()))
    if img.mode != "RGB":
        img = img.convert("RGB")
    img = img.resize(target_size)
    img = img_to_array(img) / 255.0
    img = np.expand_dims(img, axis=0)
    return img
