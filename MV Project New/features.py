import cv2
import numpy as np
import math
from skimage.feature import graycomatrix, graycoprops
from sklearn.cluster import KMeans

def apply_clahe(image):
    """
    Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
    for illumination normalization.

    Works in LAB color space to preserve colors while enhancing contrast.
    """

    # Convert to LAB color space
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)

    # Split channels
    l, a, b = cv2.split(lab)

    # Apply CLAHE only to L channel (lightness)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    l_clahe = clahe.apply(l)

    # Merge back
    lab_clahe = cv2.merge((l_clahe, a, b))

    # Convert back to BGR
    enhanced_image = cv2.cvtColor(lab_clahe, cv2.COLOR_LAB2BGR)

    return enhanced_image

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


# def extract_tissue_composition(image, mask):

#     hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

#     h = hsv[:, :, 0][mask > 0]
#     s = hsv[:, :, 1][mask > 0]
#     v = hsv[:, :, 2][mask > 0]

#     total = len(h)

#     if total == 0:
#         return {
#             "tissue_red_percent": 0,
#             "tissue_yellow_percent": 0,
#             "tissue_black_percent": 0
#         }

#     red = ((h < 10) | (h > 170)) & (s > 50) & (v > 50)
#     yellow = (h >= 15) & (h < 40) & (s > 40) & (v > 60)
#     black = v < 50

#     return {
#         "tissue_red_percent": float(np.sum(red) / total * 100),
#         "tissue_yellow_percent": float(np.sum(yellow) / total * 100),
#         "tissue_black_percent": float(np.sum(black) / total * 100)
#     }



def extract_tissue_composition_kmeans(image, mask, k=4, debug=False):
    """
    Advanced tissue classification using K-Means clustering (Improved logic)

    Handles:
    - Red (granulation)
    - Yellow (slough, pale tissue)
    - Black (necrotic)
    """

    wound_pixels = image[mask > 0]

    if len(wound_pixels) == 0:
        return {
            "tissue_red_percent": 0,
            "tissue_yellow_percent": 0,
            "tissue_black_percent": 0
        }

    pixels = wound_pixels.reshape(-1, 3).astype(np.float32)

    # 🔹 K-Means clustering
    kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
    labels = kmeans.fit_predict(pixels)
    centers = kmeans.cluster_centers_

    total_pixels = len(labels)

    red_count = 0
    yellow_count = 0
    black_count = 0

    for i in range(k):

        cluster_pixels = pixels[labels == i]
        count = len(cluster_pixels)

        #  Ignore tiny clusters (noise)
        if count / total_pixels < 0.05:
            continue

        center_bgr = np.uint8([[centers[i]]])
        center_hsv = cv2.cvtColor(center_bgr, cv2.COLOR_BGR2HSV)[0][0]

        h, s, v = center_hsv

        # if debug:
        #     print(f"Cluster {i}: HSV = {h, s, v}, Count = {count}")

        # -----------------------------------------------------
        #  IMPROVED CLASSIFICATION LOGIC
        # -----------------------------------------------------

        #  BLACK (necrotic)
        if v < 50:
            black_count += count

        #  WHITE / PALE (maceration / washed tissue)
        elif s < 40 and v > 150:
            yellow_count += count  # treat as slough for now

        #  YELLOW (slough-like)
        elif (10 <= h <= 35) or (s < 140 and v > 170):
            yellow_count += count

        #  RED (granulation)
        elif (h < 10 or h > 160) and s > 60:
            red_count += count

        #  FALLBACK
        else:
            if v < 80:
                black_count += count
            elif s < 120:
                yellow_count += count
            else:
                red_count += count

    total = red_count + yellow_count + black_count

    if total == 0:
        return {
            "tissue_red_percent": 0,
            "tissue_yellow_percent": 0,
            "tissue_black_percent": 0
        }

    return {
        "tissue_red_percent": (red_count / total) * 100,
        "tissue_yellow_percent": (yellow_count / total) * 100,
        "tissue_black_percent": (black_count / total) * 100
    }

def extract_periwound_features(image, mask, dilation_ratio=0.02):
    """
    Extract periwound (halo) features to detect inflammation.

    Improvements:
    - Circular dilation
    - Adaptive halo size
    - Noise filtering
    """

    if cv2.countNonZero(mask) == 0:
        return {
            "periwound_redness": 0.0
        }

    h, w = mask.shape

    # ---------------------------------------------------------
    # 🔹 Adaptive dilation size (based on image size)
    # ---------------------------------------------------------
    dilation_pixels = max(5, int(min(h, w) * dilation_ratio))

    # ---------------------------------------------------------
    # 🔹 Circular kernel (IMPORTANT)
    # ---------------------------------------------------------
    kernel = cv2.getStructuringElement(
        cv2.MORPH_ELLIPSE,
        (dilation_pixels, dilation_pixels)
    )

    # ---------------------------------------------------------
    # 🔹 Create halo mask
    # ---------------------------------------------------------
    dilated_mask = cv2.dilate(mask, kernel, iterations=1)
    halo_mask = cv2.subtract(dilated_mask, mask)

    # ---------------------------------------------------------
    # 🔹 Remove noise (small regions)
    # ---------------------------------------------------------
    halo_mask = cv2.medianBlur(halo_mask, 5)

    # ---------------------------------------------------------
    # 🔹 Extract redness
    # ---------------------------------------------------------
    r_channel = image[:, :, 2]
    halo_pixels = r_channel[halo_mask > 0]

    if len(halo_pixels) == 0:
        return {
            "periwound_redness": 0.0
        }

    periwound_redness = np.clip(np.mean(halo_pixels), 0, 255)

    return {
        "periwound_redness": float(periwound_redness)
    }

def compute_edge_irregularity(area, perimeter):

    if area == 0:
        return 0.0

    return float((perimeter ** 2) / (4 * math.pi * area))


def extract_features(mask, image):

    image = apply_clahe(image)

    if mask.shape != image.shape[:2]:
        mask = cv2.resize(mask, (image.shape[1], image.shape[0]))

    # 🔹 Ensure mask is single channel
    if len(mask.shape) == 3:
        mask = mask[:, :, 0]

    mask = mask.astype("uint8")

# 🔹 Step 1: Close small holes
    kernel = np.ones((5,5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

# 🔹 Step 2: Expand mask (recover missed wound boundary)
    mask = cv2.dilate(mask, kernel, iterations=2)

    # 🔹 Step 3: Fill contours (very important)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cv2.drawContours(mask, contours, -1, 255, thickness=cv2.FILLED)

    area = cv2.countNonZero(mask)

    total_pixels = mask.shape[0] * mask.shape[1]
    area_percent = (area / total_pixels) * 100

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    perimeter = sum([cv2.arcLength(c, True) for c in contours])

    r_channel = image[:, :, 2]
    redness = np.clip(np.mean(r_channel[mask > 0]), 0, 255) if area > 0 else 0

    texture = extract_texture_features(image, mask)
    tissue = extract_tissue_composition_kmeans(image, mask,k=4, debug=False)
    irregularity = compute_edge_irregularity(area, perimeter)
    periwound = extract_periwound_features(image, mask)

    return {
        "area": int(area),
        "area_percent": round(area_percent, 2),
        "perimeter": float(perimeter),
        "redness": float(redness),
        "periwound_redness": periwound["periwound_redness"],

        "texture_contrast": texture["texture_contrast"],
        "texture_homogeneity": texture["texture_homogeneity"],
        "texture_energy": texture["texture_energy"],
        "texture_entropy": texture["texture_entropy"],

        "tissue_red_percent": tissue["tissue_red_percent"],
        "tissue_yellow_percent": tissue["tissue_yellow_percent"],
        "tissue_black_percent": tissue["tissue_black_percent"],

        "edge_irregularity": irregularity
    }