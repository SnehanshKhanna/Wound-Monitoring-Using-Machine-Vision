import cv2
import matplotlib.pyplot as plt
import numpy as np

def show_results(image, mask, gt_mask=None):

    # Ensure mask is 2D
    if len(mask.shape) == 3:
        mask = mask[:, :, 0]

    mask = mask.astype("uint8")

    # Create overlay
    overlay = image.copy()

    # Red overlay
    red_layer = np.zeros_like(image)
    red_layer[:, :, 2] = 255

    overlay[mask > 0] = red_layer[mask > 0]

    plt.figure(figsize=(16,4))

    # 🔹 Original
    plt.subplot(1,4,1)
    plt.title("Original")
    plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
    plt.axis("off")

    # 🔹 Ground Truth
    if gt_mask is not None:
        if len(gt_mask.shape) == 3:
            gt_mask = gt_mask[:, :, 0]

        plt.subplot(1,4,2)
        plt.title("Ground Truth")
        plt.imshow(gt_mask, cmap="gray")
        plt.axis("off")

        pred_pos = 3
        overlay_pos = 4
    else:
        pred_pos = 2
        overlay_pos = 3

    # 🔹 Predicted Mask
    plt.subplot(1,4,pred_pos)
    plt.title("Predicted Mask")
    plt.imshow(mask, cmap="gray")
    plt.axis("off")

    # 🔹 Overlay
    plt.subplot(1,4,overlay_pos)
    plt.title("Overlay")
    plt.imshow(cv2.cvtColor(overlay, cv2.COLOR_BGR2RGB))
    plt.axis("off")

    plt.show()