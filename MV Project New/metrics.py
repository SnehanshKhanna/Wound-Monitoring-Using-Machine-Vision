import numpy as np
import cv2

def dice_score(y_true, y_pred):

    # Force same shape
    if y_true.shape != y_pred.shape:
        y_pred = cv2.resize(y_pred, (y_true.shape[1], y_true.shape[0]))

    # Convert BOTH to binary 0/1
    y_true = (y_true > 127).astype(np.uint8)
    y_pred = (y_pred > 127).astype(np.uint8)

    intersection = np.sum(y_true * y_pred)

    dice = (2 * intersection) / (np.sum(y_true) + np.sum(y_pred) + 1e-7)

    return float(dice)


def iou_score(y_true, y_pred):

    if y_true.shape != y_pred.shape:
        y_pred = cv2.resize(y_pred, (y_true.shape[1], y_true.shape[0]))

    y_true = (y_true > 127).astype(np.uint8)
    y_pred = (y_pred > 127).astype(np.uint8)

    intersection = np.logical_and(y_true, y_pred).sum()
    union = np.logical_or(y_true, y_pred).sum()

    iou = intersection / (union + 1e-7)

    return float(iou)