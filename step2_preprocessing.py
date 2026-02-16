import cv2
import os
import matplotlib.pyplot as plt

image_folder = "dataset/images"

for file in os.listdir(image_folder):
    if file.lower().endswith((".jpg", ".png")):
        img = cv2.imread(os.path.join(image_folder, file))
        img = cv2.resize(img, (256, 256))

        blur = cv2.GaussianBlur(img, (5, 5), 0)

        hsv = cv2.cvtColor(blur, cv2.COLOR_BGR2HSV)

        h, s, v = cv2.split(hsv)
        v = cv2.normalize(v, None, 0, 255, cv2.NORM_MINMAX)
        hsv_norm = cv2.merge((h, s, v))

        plt.figure(figsize=(10, 4))
        plt.subplot(1, 3, 1)
        plt.title("Original")
        plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
        plt.axis("off")

        plt.subplot(1, 3, 2)
        plt.title("HSV")
        plt.imshow(hsv)
        plt.axis("off")

        plt.subplot(1, 3, 3)
        plt.title("Illumination Normalized")
        plt.imshow(hsv_norm)
        plt.axis("off")

        plt.show()
        break