def infection_risk_score(features):
    """
    Infection risk (0–100) using:
    - Yellow tissue (slough/pus)
    - Periwound inflammation (relative)
    - Texture entropy (surface irregularity)
    """

    yellow_pct = features.get("tissue_yellow_percent", 0)
    redness = features.get("redness", 0)
    periwound = features.get("periwound_redness", 0)
    entropy = features.get("texture_entropy", 0)

    # 🔥 Relative inflammation (robust)
    periwound_delta = max(0, periwound - redness)

    # Normalize
    norm_periwound = min((periwound_delta / 50.0) * 100, 100)
    norm_entropy = min((entropy / 8.0) * 100, 100)

    infection_score = (
        (yellow_pct * 0.4) +
        (norm_periwound * 0.4) +
        (norm_entropy * 0.2)
    )

    return round(min(infection_score, 100.0), 2)


def compute_healing_score(current_features, baseline_features=None):

    # 0. No wound case
    if current_features.get("area", 0) == 0:
        return 100

    score = 40  # Balanced base

    # ---------------------------------------------------------
    # 🔹 1. Tissue Quality (IMPROVED)
    # ---------------------------------------------------------
    red = current_features.get("tissue_red_percent", 0)
    yellow = current_features.get("tissue_yellow_percent", 0)
    black = current_features.get("tissue_black_percent", 0)

    tissue_balance = red - yellow
    score += (tissue_balance * 0.4)
    score -= (black * 0.8)

    # ---------------------------------------------------------
    # 🔹 2. Area / Size
    # ---------------------------------------------------------
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

    # ---------------------------------------------------------
    # 🔹 3. Edge Irregularity
    # ---------------------------------------------------------
    irr = current_features.get("edge_irregularity", 0)

    if irr < 1.5:
        score += 10
    elif irr < 3.0:
        score += 5
    elif irr > 4.5:
        score -= 15

    # ---------------------------------------------------------
    # 🔹 4. Texture (IMPROVED)
    # ---------------------------------------------------------
    homogeneity = current_features.get("texture_homogeneity", 0)
    entropy = current_features.get("texture_entropy", 0)

    score += (homogeneity * 5)
    score -= (entropy * 1.5)

    # ---------------------------------------------------------
    # 🔹 5. Redness (vascular health)
    # ---------------------------------------------------------
    redness = current_features.get("redness", 0)

    if 100 <= redness <= 180:
        score += 10
    elif 180 < redness <= 220:
        score += 5
    elif redness > 220:
        score -= 10
    elif redness < 80:
        score -= 5

    # ---------------------------------------------------------
    # 🔥 6. Infection Risk (SMOOTH PENALTY)
    # ---------------------------------------------------------
    infection_risk = infection_risk_score(current_features)
    score -= (infection_risk * 0.3)

    # ---------------------------------------------------------
    # 🔥 7. Safety Overrides (FINAL CONTROL)
    # ---------------------------------------------------------
    if irr > 4.5:
        score = min(score, 40)

    if current_area > 2000:
        score = min(score, 55)

    if black > 5:
        score = min(score, 30)

    if infection_risk > 75:
        score = min(score, 35)

    # ---------------------------------------------------------
    # 🔹 Final clamp
    # ---------------------------------------------------------
    final_score = max(0, min(100, score))

    return round(final_score, 2)