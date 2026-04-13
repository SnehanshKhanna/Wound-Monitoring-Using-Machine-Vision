def healing_trend(current_features, previous_features):
    """
    Uses BOTH area + healing score comparison
    """

    # First image case
    if previous_features is None:
        return None

    prev_area = previous_features.get("area", 0)
    curr_area = current_features.get("area", 0)

    prev_score = previous_features.get("healing_score", None)
    curr_score = current_features.get("healing_score", None)

    # -------------------------------
    # 1. AREA BASED
    # -------------------------------
    if prev_area > 0:
        change = ((prev_area - curr_area) / prev_area) * 100

        if change > 10:
            return "Healing"
        elif change < -10:
            return "Worsening"

    # -------------------------------
    # 2. SCORE BASED (fallback)
    # -------------------------------
    if prev_score is not None and curr_score is not None:
        score_change = curr_score - prev_score

        if score_change > 5:
            return "Healing"
        elif score_change < -5:
            return "Worsening"

    return "Stable"