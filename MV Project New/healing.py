def healing_trend(area_list):

    if len(area_list) < 2:
        return "Insufficient data"

    change = area_list[-1] - area_list[0]

    if change < -500:
        return "Healing"
    elif change > 500:
        return "Worsening"
    else:
        return "Stable"