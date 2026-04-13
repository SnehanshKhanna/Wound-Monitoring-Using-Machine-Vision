import cv2
import os
import random

from firebase_db import get_previous_features, save_features
from healing import healing_trend
from predict import predict_mask
from features import extract_features
from decision import risk_level
from scoring import compute_healing_score
from scoring import infection_risk_score

from metrics import dice_score, iou_score
from visualize import show_results

def analyze(image_path, user_id="default_user", gt_mask_path=None, visualize=False):

    # -------------------------------
    # Load image
    # -------------------------------
    image = cv2.imread(image_path)

    if image is None:
        raise ValueError(f" Image not found: {image_path}")

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
    # Get previous data
    # -------------------------------
    previous_features = get_previous_features(user_id)

    print(" Previous features:", previous_features)

    # -------------------------------
    # Scoring + Risk
    # -------------------------------
    healing_score = compute_healing_score(features)
    infection_risk_result = infection_risk_score(features)
    risk = risk_level(healing_score, features)

    # -------------------------------
    # Healing Trend
    # -------------------------------
    trend = healing_trend(
        {**features, "healing_score": healing_score},
        previous_features
    )

    print(" Computed trend:", trend)

    # -------------------------------
    # Base results
    # -------------------------------
    results = {
        "area": features["area"],
        "area_percent": features["area_percent"],
        "perimeter": features["perimeter"],
        "redness": features["redness"],
        "periwound_redness": features["periwound_redness"],
        "risk_level": risk,
        "infection_risk_score": infection_risk_result,
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
    # Add healing trend
    # -------------------------------
    if trend is not None:
        results["healing_trend"] = trend

    # -------------------------------
    # METRICS (optional)
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

    # -------------------------------
    # Save current data to Firebase
    # -------------------------------
    save_features(user_id, {
        **features,
        "healing_score": healing_score
    })

    print("Saved current data")

    # -------------------------------
    # Visualization
    # -------------------------------
    if visualize:
        try:
            if gt_mask is not None:
                show_results(image, pred_mask, gt_mask)
            else:
                show_results(image, pred_mask)
        except Exception as e:
            print(f" Visualization error: {e}")

    return results


# -------------------------------
# LOCAL TEST
# -------------------------------
if __name__ == "__main__":

    test_folder = "data_wound_seg/test_images"
    files = [f for f in os.listdir(test_folder) if f.endswith((".jpg", ".png", ".jpeg"))]

    # if len(files) == 0:
    #     print(" No images found")
    # else:
    #     test_image = os.path.join(test_folder, random.choice(files))

    #     print("Using image:", test_image)

    result = analyze(
        image_path="fusc_0023.png",
        user_id="test_user",   # SAME USER FOR TEST
        gt_mask_path=None,
        visualize=False
    )

    print("\n✅ FINAL RESULT:")
    print(result)
    