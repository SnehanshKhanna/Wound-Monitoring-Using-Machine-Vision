# import cv2
# from predict import predict_mask
# from features import extract_features
# from decision import risk_level
# from scoring import compute_healing_score

# def analyze(image_path):

#     image = cv2.imread(image_path)
#     image = cv2.resize(image, (256,256))
#     mask = predict_mask(image)

#     features = extract_features(mask, image)

#     healing_score = compute_healing_score(features)
#     risk = risk_level(healing_score, features)


#     return {
#     "area": features["area"],
#     "area_percent": features["area_percent"],
#     "perimeter": features["perimeter"],
#     "redness": features["redness"],
#     "risk_level": risk,
#     "healing_score": healing_score,
#     # Texture features
#     "texture_contrast": features["texture_contrast"],
#     "texture_homogeneity": features["texture_homogeneity"],
#     "texture_energy": features["texture_energy"],
#     "texture_entropy": features["texture_entropy"],
#     # Tissue composition
#     "tissue_red_percent": features["tissue_red_percent"],
#     "tissue_yellow_percent": features["tissue_yellow_percent"],
#     "tissue_black_percent": features["tissue_black_percent"],
#     # Edge irregularity
#     "edge_irregularity": features["edge_irregularity"]
# }


# # TEST
# if __name__ == "__main__":

#     result = analyze(
#         "fusc_0027.png")

#     print(result)


# import cv2
# from predict import predict_mask
# from features import extract_features
# from decision import risk_level
# from scoring import compute_healing_score

# # NEW IMPORTS
# from metrics import dice_score, iou_score
# from visualize import show_results


# def analyze(image_path, gt_mask_path, visualize=True):

#     # Load image
#     image = cv2.imread(image_path)
#     image = cv2.resize(image, (256,256))

#     # Predict mask
#     pred_mask = predict_mask(image)

#     # Extract features
#     features = extract_features(pred_mask, image)

#     # Compute score + risk
#     healing_score = compute_healing_score(features)
#     risk = risk_level(healing_score, features)

#     results = {
#         "area": features["area"],
#         "area_percent": features["area_percent"],
#         "perimeter": features["perimeter"],
#         "redness": features["redness"],
#         "risk_level": risk,
#         "healing_score": healing_score,

#         # Texture
#         "texture_contrast": features["texture_contrast"],
#         "texture_homogeneity": features["texture_homogeneity"],
#         "texture_energy": features["texture_energy"],
#         "texture_entropy": features["texture_entropy"],

#         # Tissue
#         "tissue_red_percent": features["tissue_red_percent"],
#         "tissue_yellow_percent": features["tissue_yellow_percent"],
#         "tissue_black_percent": features["tissue_black_percent"],

#         # Shape
#         "edge_irregularity": features["edge_irregularity"]
#     }

#     # ---------------------------------------------------
#     # ✅ METRICS (only if GT mask is provided)
#     # ---------------------------------------------------
#     if gt_mask_path is not None:
#         gt_mask = cv2.imread(gt_mask_path, 0)
#         gt_mask = cv2.resize(gt_mask, (256,256))

#         dice = dice_score(gt_mask, pred_mask)
#         iou = iou_score(gt_mask, pred_mask)

#         results["dice_score"] = dice
#         results["iou_score"] = iou
#     else:
#         gt_mask = None

#     # ---------------------------------------------------
#     # ✅ VISUALIZATION (optional)
#     # ---------------------------------------------------
#     if visualize:
#         show_results(image, pred_mask, gt_mask)

#     return results


# # ---------------------------------------------------
# # TEST
# # ---------------------------------------------------
# if __name__ == "__main__":

#     result = analyze(
#         "fusc_0026.png",
#         # Example if you have GT:
#         gt_mask_path="fusc_0026_mask.png",
#         visualize=True
#     )

#     print(result)


import cv2
import os

import os

from predict import predict_mask
from features import extract_features
from decision import risk_level
from scoring import compute_healing_score

from metrics import dice_score, iou_score
from visualize import show_results


def analyze(image_path, gt_mask_path=None, visualize=False):

    # -------------------------------
    # Load image
    # -------------------------------
    image = cv2.imread(image_path)

    if image is None:
        raise ValueError(f"❌ Image not found: {image_path}")

    image = cv2.resize(image, (256, 256))

    # -------------------------------
    # Predict mask
    # -------------------------------
    pred_mask = predict_mask(image)

    # -------------------------------
    # Feature extraction
    # -------------------------------
    features = extract_features(pred_mask, image)

    # -------------------------------
    # Scoring + Risk
    # -------------------------------
    healing_score = compute_healing_score(features)
    risk = risk_level(healing_score, features)

    # -------------------------------
    # Base results
    # -------------------------------
    results = {
        "area": features["area"],
        "area_percent": features["area_percent"],
        "perimeter": features["perimeter"],
        "redness": features["redness"],
        "risk_level": risk,
        "healing_score": healing_score,

        # Texture
        "texture_contrast": features["texture_contrast"],
        "texture_homogeneity": features["texture_homogeneity"],
        "texture_energy": features["texture_energy"],
        "texture_entropy": features["texture_entropy"],

        # Tissue
        "tissue_red_percent": features["tissue_red_percent"],
        "tissue_yellow_percent": features["tissue_yellow_percent"],
        "tissue_black_percent": features["tissue_black_percent"],

        # Shape
        "edge_irregularity": features["edge_irregularity"]
    }

    # -------------------------------
    # METRICS (only if GT exists)
    # -------------------------------
    gt_mask = None

    if gt_mask_path is not None and os.path.exists(gt_mask_path):
        gt_mask = cv2.imread(gt_mask_path, 0)

        if gt_mask is not None:
            gt_mask = cv2.resize(gt_mask, (256, 256))

            dice = dice_score(gt_mask, pred_mask)
            iou = iou_score(gt_mask, pred_mask)

            results["dice_score"] = round(dice, 4)
            results["iou_score"] = round(iou, 4)
        else:
            print(f"⚠️ Failed to load GT mask: {gt_mask_path}")
    else:
        if gt_mask_path is not None:
            print(f"⚠️ GT mask not found: {gt_mask_path}")

    print(results)
    # -------------------------------
    # VISUALIZATION
    # -------------------------------
    if visualize:
        try:
            if gt_mask is not None:
                show_results(image, pred_mask, gt_mask)
            else:
                show_results(image, pred_mask)
        except Exception as e:
            print(f"⚠️ Visualization error: {e}")

    return results


# -------------------------------
# TEST
# -------------------------------
if __name__ == "__main__":

    test_folder = "data_wound_seg/test_images"
    files = os.listdir(test_folder)

    files = [f for f in files if f.endswith((".jpg", ".png", ".jpeg"))]

    if len(files) == 0:
        print("❌ No images found")
    else:
        test_image = os.path.join(test_folder, random.choice(files))

        print("Using image:", test_image)

    result = analyze(
        image_path="fusc_0026.png",
        # 🔥 IMPORTANT: use correct path
        gt_mask_path="fusc_0026_mask.png",
        visualize=True
    )

    