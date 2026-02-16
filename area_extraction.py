import cv2 
import numpy as np
import os

image_folder = "dataset/images"

for file in os.listdir(image_folder):
    if file.lower().endswith((".jpg", ".png")):
        img = cv2.imread(os.path.join(image_folder, file))
        img = cv2.resize(img, (256, 256))
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        mask = cv2.inRange(hsv, (0, 30, 30), (25, 255, 255))
        area = cv2.countNonZero(mask)

        print(f"{file} → Wound Area (pixels): {area}")
        break