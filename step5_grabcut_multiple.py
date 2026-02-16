import cv2
import numpy as np
import os
import matplotlib.pyplot as plt

image_folder = "dataset/images"

boxes = [
    (140, 70, 90, 90),   
    (20, 40, 80, 80)     
]

for file in os.listdir(image_folder):
    if file.lower().endswith((".jpg", ".png")):
        img = cv2.imread(os.path.join(image_folder, file))
        img = cv2.resize(img, (256,256))

        final_mask = np.zeros(img.shape[:2], dtype=np.uint8)

        for rect in boxes:
            mask = np.zeros(img.shape[:2], np.uint8)
            bgModel = np.zeros((1,65), np.float64)
            fgModel = np.zeros((1,65), np.float64)

            cv2.grabCut(img, mask, rect, bgModel, fgModel, 5, cv2.GC_INIT_WITH_RECT)

            wound_mask = np.where(
                (mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD),
                255, 0
            ).astype("uint8")

            final_mask = cv2.bitwise_or(final_mask, wound_mask)

        
        img_box = img.copy()
        for (x,y,w,h) in boxes:
            cv2.rectangle(img_box, (x,y), (x+w,y+h), (0,255,0), 2)

        plt.figure(figsize=(10,4))
        plt.subplot(1,3,1)
        plt.title("Original")
        plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
        plt.axis("off")

        plt.subplot(1,3,2)
        plt.title("GrabCut Init Boxes")
        plt.imshow(cv2.cvtColor(img_box, cv2.COLOR_BGR2RGB))
        plt.axis("off")

        plt.subplot(1,3,3)
        plt.title("Final GrabCut Mask")
        plt.imshow(final_mask, cmap="gray")
        plt.axis("off")

        plt.show()
        break