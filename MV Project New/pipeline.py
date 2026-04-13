import cv2
import os

from predict import predict_mask
from features import extract_features
from healing import healing_trend
from decision import risk_level
from metrics import dice_score, iou_score
from visualize import show_results


def analyze(image_path, previous_areas=None, visualize=False):

    image = cv2.imread(image_path)
    image = cv2.resize(image, (256,256))

    mask = predict_mask(image)

    features = extract_features(mask, image)

    risk = risk_level(features["area_percent"], features["redness"])

    # Healing
    if previous_areas:
        trend = healing_trend(previous_areas + [features["area"]])
    else:
        trend = "N/A"

    # 🔥 Ground truth mask
    filename = os.path.basename(image_path)
    gt_path = os.path.join("data_wound_seg", "test_masks", filename)

    if os.path.exists(gt_path):
        gt_mask = cv2.imread(gt_path, 0)
        gt_mask = cv2.resize(gt_mask, (256,256))

        dice = dice_score(gt_mask, mask)
        iou = iou_score(gt_mask, mask)
    else:
        dice, iou = None, None

    # 🔥 Visualization
    if visualize:
        if os.path.exists(gt_path):
            show_results(image, mask, gt_mask)
        else:
            show_results(image, mask)

    return {
        "area": features["area"],
        "area_percent": features["area_percent"],
        "perimeter": features["perimeter"],
        "irregularity": features["irregularity"],
        "redness": features["redness"],
        "risk_level": risk,
        "healing_trend": trend,
        "dice_score": round(dice, 3) if dice is not None else None,  # ✅ FIXED
        "iou": round(iou, 3) if iou is not None else None           # ✅ FIXED
    }


# TEST
import random

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
            test_image,
            previous_areas=[12000, 11000]
        )

        print(result)