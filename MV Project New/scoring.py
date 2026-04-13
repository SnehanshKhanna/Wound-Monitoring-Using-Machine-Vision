# def compute_healing_score(features):
#     score = 0

#     # 1. Tissue (MOST IMPORTANT)
#     red = features["tissue_red_percent"]
#     black = features["tissue_black_percent"]

#     score += red * 0.5
#     score -= black * 0.7

#     # 2. Area (NEW — VERY IMPORTANT)
#     area = features["area"]

#     if area < 500:
#         score += 20
#     elif area < 1500:
#         score += 10
#     else:
#         score -= 10

#     # 3. Irregularity (less weight now)
#     irr = features["edge_irregularity"]

#     if irr < 1.5:
#         score += 10
#     elif irr < 2.5:
#         score += 5
#     else:
#         score += 0   # no penalty

#     # 4. Texture homogeneity
#     score += features["texture_homogeneity"] * 15

#     # 5. Redness (FIXED logic)
#     redness = features["redness"]

#     if redness > 80:
#         score += 10   # allow high redness
#     else:
#         score -= 5

#     # Clamp
#     score = max(0, min(100, score))

#     return round(score, 2)

def compute_healing_score(current_features, baseline_features=None):
    """
    Calculates a dynamic healing score (0-100) by comparing current wound metrics
    against a baseline (previous visit).
    """
    # Start with a base score that we will add to or subtract from
    score = 20  

    # ---------------------------------------------------------
    # 1. TISSUE COMPOSITION (Static Snapshot - Still crucial)
    # ---------------------------------------------------------
    red = current_features.get("tissue_red_percent", 0)
    black = current_features.get("tissue_black_percent", 0)
    yellow = current_features.get("tissue_yellow_percent", 0)

    # Reward healthy granulation heavily, penalize necrosis/slough
    score += (red * 0.4)    # Max +40 points
    score -= (black * 0.8)  # Heavy penalty for black eschar
    score -= (yellow * 0.3) # Moderate penalty for yellow slough

    # ---------------------------------------------------------
    # 2. AREA CONTRACTION (Dynamic - The true measure of healing)
    # ---------------------------------------------------------
    current_area = current_features.get("area", 0)
    
    if baseline_features and "area" in baseline_features and baseline_features["area"] > 0:
        baseline_area = baseline_features["area"]
        
        # Calculate percentage change: positive means shrinkage (good)
        area_change_pct = ((baseline_area - current_area) / baseline_area) * 100
        
        if area_change_pct > 20:
            score += 25  # Significant contraction
        elif area_change_pct > 5:
            score += 15  # Moderate contraction
        elif area_change_pct > -5:
            score += 0   # Stagnant (no significant change)
        else:
            score -= 20  # WOUND EXPANDED (Warning sign)
    else:
        # Fallback if this is the first visit (no baseline available)
        if current_area < 500:
            score += 10
        elif current_area > 2000:
            score -= 10

    # ---------------------------------------------------------
    # 3. EDGE IRREGULARITY (Penalize deep/complex morphologies)
    # ---------------------------------------------------------
    irr = current_features.get("edge_irregularity", 0)

    if irr < 1.5:
        score += 10  # Smooth, uniform edges
    elif irr < 3.0:
        score += 5   # Normal slight irregularity during epithelialization
    elif irr > 4.5:
        score -= 15  # Severe penalty (Flags complex/clefted wounds)

    # ---------------------------------------------------------
    # 4. TEXTURE HOMOGENEITY
    # ---------------------------------------------------------
    # Higher homogeneity usually means smoother, more uniform tissue
    score += (current_features.get("texture_homogeneity", 0) * 5)

    # ---------------------------------------------------------
    # 5. REDNESS ("Goldilocks Zone")
    # ---------------------------------------------------------
    redness = current_features.get("redness", 0)

    if 100 <= redness <= 180:
        score += 10  # Healthy, beefy red granulation tissue
    elif redness > 220:
        score -= 10  # Danger: Extreme redness often indicates hyperemia/infection
    elif redness > 180:
        score += 5   # Mildly elevated redness can be normal during active healing
    elif redness < 80:
        score -= 5   # Danger: Too pale, possible ischemia/poor blood flow

    # ---------------------------------------------------------
    # CLAMP SCORE (Ensure it stays between 0 and 100)
    # ---------------------------------------------------------
    final_score = max(0, min(100, score))

    # ---------------------------------------------------------
# 6. HARD SAFETY OVERRIDES (CRITICAL CASES)
# ---------------------------------------------------------
    irr = current_features.get("edge_irregularity", 0)
    area = current_features.get("area", 0)
    black = current_features.get("tissue_black_percent", 0)

    # Severe morphology
    if irr > 4.5:
        score = min(score, 40)

    # Very large wound
    if area > 2000:
        score = min(score, 50)

    # Necrosis present
    if black > 5:
        score = min(score, 30)

    return round(final_score, 2)