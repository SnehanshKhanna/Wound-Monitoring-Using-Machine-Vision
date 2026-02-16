import cv2
import numpy as np
import os
import matplotlib.pyplot as plt

image_folder = "dataset/images"

for file in os.listdir(image_folder):
    if file.lower().endswith((".jpg", ".png")):
        img = cv2.imread(os.path.join(image_folder, file))
        img = cv2.resize(img, (256,256))
        blur = cv2.GaussianBlur(img, (5,5), 0)
        hsv = cv2.cvtColor(blur, cv2.COLOR_BGR2HSV)

        lower1 = np.array([0, 50, 50])
        upper1 = np.array([10, 255, 255])
        lower2 = np.array([160, 50, 50])
        upper2 = np.array([180, 255, 255])

        mask = cv2.inRange(hsv, lower1, upper1) + cv2.inRange(hsv, lower2, upper2)

        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7,7))
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

        plt.imshow(mask, cmap="gray")
        plt.title("Initial HSV Segmentation")
        plt.axis("off")
        plt.show()
        break