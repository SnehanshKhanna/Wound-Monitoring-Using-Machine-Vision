import cv2
import numpy as np
from tensorflow.keras.models import load_model

model = load_model("unet_model.h5")

def predict_mask(image):

    img = cv2.resize(image, (256,256))
    img = img / 255.0
    img = np.expand_dims(img, axis=0)

    pred = model.predict(img)[0]

    mask = (pred > 0.5).astype("uint8") * 255

    return mask