import cv2
import numpy as np

def extract_features(mask, image):

    # Ensure same size
    if mask.shape != image.shape[:2]:
        mask = cv2.resize(mask, (image.shape[1], image.shape[0]))

    if len(mask.shape) == 3:
        mask = mask[:, :, 0]

    mask = mask.astype("uint8")

    # Area
    area = cv2.countNonZero(mask)

    # 🔥 ADD THIS
    total_pixels = mask.shape[0] * mask.shape[1]
    area_percent = (area / total_pixels) * 100

    # Perimeter
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    perimeter = sum([cv2.arcLength(c, True) for c in contours])

    # HSV
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    masked_pixels = hsv[:, :, 0][mask > 0]
    redness = np.mean(masked_pixels) if len(masked_pixels) > 0 else 0

    return {
        "area": int(area),
        "area_percent": round(area_percent, 2),  # 🔥 NEW
        "perimeter": float(perimeter),
        "redness": float(redness)
    }