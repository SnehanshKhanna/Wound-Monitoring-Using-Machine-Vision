def compute_healing_score(current_features, baseline_features=None):

    # 0. No wound case
    if current_features.get("area", 0) == 0:
        return 100

    score = 20

    # 1. Tissue
    red = current_features.get("tissue_red_percent", 0)
    black = current_features.get("tissue_black_percent", 0)
    yellow = current_features.get("tissue_yellow_percent", 0)

    score += (red * 0.4)
    score -= (black * 0.8)
    score -= (yellow * 0.3)

    # 2. Area contraction
    current_area = current_features.get("area", 0)

    if baseline_features and baseline_features.get("area", 0) > 0:
        baseline_area = baseline_features["area"]
        area_change_pct = ((baseline_area - current_area) / baseline_area) * 100

        if area_change_pct > 20:
            score += 25
        elif area_change_pct > 5:
            score += 15
        elif area_change_pct < -5:
            score -= 20
    else:
        if current_area < 500:
            score += 15
        elif current_area > 2000:
            score -= 15

    # 3. Irregularity
    irr = current_features.get("edge_irregularity", 0)

    if irr < 1.5:
        score += 10
    elif irr < 3.0:
        score += 5
    elif irr > 4.5:
        score -= 15

    # 4. Texture
    score += current_features.get("texture_homogeneity", 0) * 5

    # 5. Redness
    redness = current_features.get("redness", 0)

    if 100 <= redness <= 180:
        score += 10
    elif 180 < redness <= 220:
        score += 5
    elif redness > 220:
        score -= 10
    elif redness < 80:
        score -= 5

    #  6. Safety overrides
    if irr > 4.5:
        score = min(score, 40)

    if current_area > 2000:
        score = min(score, 50)

    if black > 5:
        score = min(score, 30)

    # Final clamp
    final_score = max(0, min(100, score))

    return round(final_score, 2)