import os
import cv2
import matplotlib.pyplot as plt

image_folder = "dataset/images"

for file in os.listdir(image_folder):
    if file.lower().endswith((".jpg", ".jpeg", ".png")):
        path = os.path.join(image_folder, file)
        img = cv2.imread(path)

        if img is None:
            print(f"Could not read {file}")
            continue

        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        plt.imshow(img)
        plt.title(f"Loaded Image: {file}")
        plt.axis("off")
        plt.show()

        break   