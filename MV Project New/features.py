import cv2
import numpy as np

def extract_features(mask, image):

    # 🔹 Ensure mask and image are same size
    if mask.shape != image.shape[:2]:
        mask = cv2.resize(mask, (image.shape[1], image.shape[0]))

    # 🔹 Ensure mask is single channel
    if len(mask.shape) == 3:
        mask = mask[:, :, 0]

    # 🔹 Convert to binary mask (0 or 255)
    mask = (mask > 0).astype("uint8") * 255

    # 🔹 AREA
    area = cv2.countNonZero(mask)

    total_pixels = mask.shape[0] * mask.shape[1]
    area_percent = (area / total_pixels) * 100

    # 🔹 PERIMETER
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    perimeter = sum([cv2.arcLength(c, True) for c in contours])

    # 🔹 IRREGULARITY (Shape complexity)
    if area > 0:
        irregularity = (perimeter ** 2) / (4 * np.pi * area)
    else:
        irregularity = 0

    # 🔹 CORRECT REDNESS (BGR RED CHANNEL)
    red_pixels = image[:, :, 2][mask > 0]

    if len(red_pixels) > 0:
        redness = np.mean(red_pixels)
    else:
        redness = 0

    return {
        "area": int(area),
        "area_percent": round(area_percent, 2),
        "perimeter": float(perimeter),
        "irregularity": round(irregularity, 2),
        "redness": float(redness)
    }