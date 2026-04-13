def risk_level(healing_score, features):

    irr = features.get("edge_irregularity", 0)
    black = features.get("tissue_black_percent", 0)
    yellow = features.get("tissue_yellow_percent", 0)
    area = features.get("area", 0)
    area_percent = features.get("area_percent", 0)

    # ---------------------------------------------------------
    # 0. NO WOUND DETECTED (VERY IMPORTANT)
    # ---------------------------------------------------------
    if area == 0 or area_percent < 0.1:
        return "No Significant Wound Detected"

    # ---------------------------------------------------------
    # 1. HIGH-RISK OVERRIDES
    # ---------------------------------------------------------
    if irr > 4.5:
        return "High Risk (Irregular / Deep Tissue)"
    
    if black > 10:
        return "High Risk (Necrotic Tissue Present)"
    
    if area > 2500:
        return "High Risk (Large Wound Area)"

    # ---------------------------------------------------------
    # 2. MODERATE RISK
    # ---------------------------------------------------------
    if yellow > 25:
        return "Moderate Risk (Slough Present)"

    # ---------------------------------------------------------
    # 3. SCORE-BASED
    # ---------------------------------------------------------
    if healing_score >= 75:
        return "Low Risk (Healing Well)"
    elif healing_score >= 50:
        return "Moderate Risk"
    else:
        return "High Risk (Poor Healing)"