def risk_level(area_percent, redness):

    if area_percent > 5 or redness > 10:
        return "High Risk"
    elif area_percent > 2:
        return "Moderate Risk"
    else:
        return "Low Risk"