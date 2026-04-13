import os
import cv2
import numpy as np
from unet_model import build_unet

IMG_SIZE = 256

def load_data(img_dir, mask_dir):

    images = []
    masks = []

    for file in os.listdir(img_dir):

        img_path = os.path.join(img_dir, file)
        mask_path = os.path.join(mask_dir, file)

        if not os.path.exists(mask_path):
            continue

        img = cv2.imread(img_path)
        img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))

        mask = cv2.imread(mask_path, 0)
        mask = cv2.resize(mask, (IMG_SIZE, IMG_SIZE))

        mask = mask / 255.0
        mask = np.expand_dims(mask, axis=-1)

        images.append(img / 255.0)
        masks.append(mask)

    return np.array(images), np.array(masks)


# Load training data
X_train, y_train = load_data(
    "data_wound_seg/train_images",
    "data_wound_seg/train_masks"
)

# Build model
model = build_unet()

model.compile(
    optimizer='adam',
    loss='binary_crossentropy',
    metrics=['accuracy']
)

# Train
model.fit(
    X_train, y_train,
    epochs=10,
    batch_size=8
)

model.save("unet_model.h5")

print("✅ Training complete")