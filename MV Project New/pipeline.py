import cv2
from predict import predict_mask
from features import extract_features
from healing import healing_trend
from decision import risk_level

def analyze(image_path, previous_areas=None):

    image = cv2.imread(image_path)
    image = cv2.resize(image, (256,256))
    mask = predict_mask(image)

    features = extract_features(mask, image)

    risk = risk_level(features["area_percent"], features["redness"])

    if previous_areas:
        trend = healing_trend(previous_areas + [features["area"]])
    else:
        trend = "N/A"

    return {
    "area": features["area"],
    "area_percent": features["area_percent"],
    "perimeter": features["perimeter"],
    "redness": features["redness"],
    "risk_level": risk,
    "healing_trend": trend
}


# TEST
if __name__ == "__main__":

    result = analyze(
        "data_wound_seg/test_images/fusc_0026.png",
        previous_areas=[12000, 11000]
    )

    print(result)