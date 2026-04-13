import cv2
import numpy as np
import math
from skimage.feature import graycomatrix, graycoprops


def extract_texture_features(image, mask):

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# Find wound bounding box
    ys, xs = np.where(mask > 0)

    if len(xs) > 0 and len(ys) > 0:
        x_min, x_max = xs.min(), xs.max()
        y_min, y_max = ys.min(), ys.max()

        cropped = gray[y_min:y_max+1, x_min:x_max+1]
        cropped_mask = mask[y_min:y_max+1, x_min:x_max+1]

        # Remove background
        cropped = cropped * (cropped_mask > 0)
    else:
        cropped = gray

    cropped = cv2.normalize(cropped, None, 0, 255, cv2.NORM_MINMAX)
    cropped = cropped.astype("uint8")

    if np.sum(cropped) == 0:
        return {
            "texture_contrast": 0.0,
            "texture_homogeneity": 0.0,
            "texture_energy": 0.0,
            "texture_entropy": 0.0
        }

    glcm = graycomatrix(
        cropped,
        distances=[1],
        angles=[0, np.pi/4, np.pi/2, 3*np.pi/4],
        levels=256,
        symmetric=True,
        normed=True
    )

    contrast = graycoprops(glcm, 'contrast').mean()
    homogeneity = graycoprops(glcm, 'homogeneity').mean()
    energy = graycoprops(glcm, 'energy').mean()

    # Entropy (only wound region)
    wound_pixels = gray[mask > 0]

    if len(wound_pixels) > 0:
        hist, _ = np.histogram(wound_pixels, bins=256, range=(0, 256))
        hist = hist / hist.sum()
        hist = hist + 1e-8
        entropy = -np.sum(hist * np.log2(hist))
    else:
        entropy = 0

    return {
        "texture_contrast": float(contrast),
        "texture_homogeneity": float(homogeneity),
        "texture_energy": float(energy),
        "texture_entropy": float(entropy)
    }


def extract_tissue_composition(image, mask):

    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    h = hsv[:, :, 0][mask > 0]
    s = hsv[:, :, 1][mask > 0]
    v = hsv[:, :, 2][mask > 0]

    total = len(h)

    if total == 0:
        return {
            "tissue_red_percent": 0,
            "tissue_yellow_percent": 0,
            "tissue_black_percent": 0
        }

    red = ((h < 10) | (h > 170)) & (s > 50) & (v > 50)
    yellow = (h >= 15) & (h < 40) & (s > 40) & (v > 60)
    black = v < 50

    return {
        "tissue_red_percent": float(np.sum(red) / total * 100),
        "tissue_yellow_percent": float(np.sum(yellow) / total * 100),
        "tissue_black_percent": float(np.sum(black) / total * 100)
    }


def compute_edge_irregularity(area, perimeter):

    if area == 0:
        return 0.0

    return float((perimeter ** 2) / (4 * math.pi * area))


def extract_features(mask, image):

    if mask.shape != image.shape[:2]:
        mask = cv2.resize(mask, (image.shape[1], image.shape[0]))

    # 🔹 Ensure mask is single channel
    if len(mask.shape) == 3:
        mask = mask[:, :, 0]

    mask = mask.astype("uint8")
    kernel = np.ones((3,3), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

    area = cv2.countNonZero(mask)

    total_pixels = mask.shape[0] * mask.shape[1]
    area_percent = (area / total_pixels) * 100

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    perimeter = sum([cv2.arcLength(c, True) for c in contours])

    r_channel = image[:, :, 2]
    redness = np.clip(np.mean(r_channel[mask > 0]), 0, 255) if area > 0 else 0

    texture = extract_texture_features(image, mask)
    tissue = extract_tissue_composition(image, mask)
    irregularity = compute_edge_irregularity(area, perimeter)

    return {
        "area": int(area),
        "area_percent": round(area_percent, 2),
        "perimeter": float(perimeter),
        "redness": float(redness),

        "texture_contrast": texture["texture_contrast"],
        "texture_homogeneity": texture["texture_homogeneity"],
        "texture_energy": texture["texture_energy"],
        "texture_entropy": texture["texture_entropy"],

        "tissue_red_percent": tissue["tissue_red_percent"],
        "tissue_yellow_percent": tissue["tissue_yellow_percent"],
        "tissue_black_percent": tissue["tissue_black_percent"],

        "edge_irregularity": irregularity
    }