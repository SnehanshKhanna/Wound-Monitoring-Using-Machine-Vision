def healing_trend_area(area_list):
    """
    Legacy method: Uses wound area change
    """

    if len(area_list) < 2:
        return "Insufficient data"

    change = area_list[-1] - area_list[0]

    if change < -500:
        return "Healing"
    elif change > 500:
        return "Worsening"
    else:
        return "Stable"


def healing_trend_score(score_list):
    """
    Improved method: Uses healing score change (recommended)
    """

    if len(score_list) < 2:
        return "Insufficient data"

    change = score_list[-1] - score_list[0]

    if change > 5:
        return "Healing"
    elif change < -5:
        return "Worsening"
    else:
        return "Stable"