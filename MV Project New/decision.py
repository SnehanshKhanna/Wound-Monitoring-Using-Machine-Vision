def risk_level(healing_score, features):
    # Extract key red flag metrics
    irr = features.get("edge_irregularity", 0)
    black = features.get("tissue_black_percent", 0)
    yellow = features.get("tissue_yellow_percent", 0)
    area = features.get("area", 0)

    # ---------------------------------------------------------
    # 1. IMMEDIATE HIGH-RISK OVERRIDES
    # If any of these critical thresholds are met, escalate immediately.
    # ---------------------------------------------------------
    if irr > 4.5:
        return "High Risk (Complex Morphology/Deep Tissue)"
    if black > 10:
        return "High Risk (Significant Necrosis Present)"
    if area > 2500:
        return "High Risk (Extensive Surface Area)"
    
    # ---------------------------------------------------------
    # 2. MODERATE RISK OVERRIDES
    # ---------------------------------------------------------
    if yellow > 25:
        return "Moderate Risk (High Slough/Infection Risk)"

    # ---------------------------------------------------------
    # 3. SCORE-BASED FALLBACK
    # If no red flags are triggered, rely on the general healing score.
    # ---------------------------------------------------------
    if healing_score >= 75:
        return "Low Risk (Healing Well)"
    elif healing_score >= 50:
        return "Moderate Risk"
    else:
        return "High Risk"