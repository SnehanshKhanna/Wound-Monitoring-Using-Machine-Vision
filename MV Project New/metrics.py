import numpy as np

def dice_score(y_true, y_pred):

    y_true = y_true.flatten()
    y_pred = y_pred.flatten()

    intersection = np.sum(y_true * y_pred)

    return (2 * intersection) / (np.sum(y_true) + np.sum(y_pred) + 1e-7)


def iou_score(y_true, y_pred):

    intersection = np.logical_and(y_true, y_pred)
    union = np.logical_or(y_true, y_pred)

    return np.sum(intersection) / np.sum(union)