from scoring import calculate_infection_risk

def risk_level(healing_score, features):

    irr = features.get("edge_irregularity", 0)
    black = features.get("tissue_black_percent", 0)
    yellow = features.get("tissue_yellow_percent", 0)
    area = features.get("area", 0)
    area_percent = features.get("area_percent", 0)

    # ---------------------------------------------------------
    # 🔥 0. NO WOUND
    # ---------------------------------------------------------
    if area == 0 or area_percent < 0.1:
        return "No Significant Wound Detected"

    # ---------------------------------------------------------
    # 🔥 Infection signal
    # ---------------------------------------------------------
    infection_risk = calculate_infection_risk(features)

    # ---------------------------------------------------------
    # 1. HIGH-RISK OVERRIDES (STRUCTURAL FIRST)
    # ---------------------------------------------------------
    if irr > 8:
        return "High Risk (Severe Structural Damage)"

    elif irr > 4.5:
        if black > 5 or yellow > 40:
            return "High Risk (Irregular + Poor Tissue)"

    if black > 10:
        return "High Risk (Necrotic Tissue Present)"

    # ---------------------------------------------------------
# 🔥 Large wound logic (FINAL VERSION)
# ---------------------------------------------------------
    if area > 4000:
        if infection_risk > 60 or yellow > 50:
            return "High Risk (Severe Large Wound)"
        elif healing_score > 50:
            return "Moderate Risk (Large but Healing)"
        else:
            return "High Risk (Large + Complicated Wound)"

    elif area > 2500:
        if infection_risk > 50 or yellow > 40 or healing_score < 40:
            return "High Risk (Large + Complicated Wound)"

        # 🔥 Severe infection
        if infection_risk > 75:
            return "High Risk (Severe Infection / Exudate)"

        # 🔥 Combined slough + infection (VERY IMPORTANT FIX)
        if infection_risk > 50 and yellow > 50:
            return "High Risk (Slough + Infection)"

    # ---------------------------------------------------------
    # 2. MODERATE RISK CONDITIONS
    # ---------------------------------------------------------
    if infection_risk > 50:
        return "Moderate Risk (Infection/Inflammation)"

    if yellow > 30 and healing_score < 70:
        return "Moderate Risk (Heavy Slough Present)"

    # ---------------------------------------------------------
    # 3. SCORE-BASED FINAL DECISION
    # ---------------------------------------------------------
    if healing_score >= 75:
        return "Low Risk (Healing Well)"

    elif healing_score >= 55:
        return "Moderate Risk"

    else:
        return "High Risk (Poor Healing!)"