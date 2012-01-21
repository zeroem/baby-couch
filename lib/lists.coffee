
exports.chart = (head,req) ->
    start
        headers:
            "Content-Type": "text/html"

    days = {}

    get_duration_minutes = (doc) ->
        Math.floor(doc.duration/60)

    while doc = getRow()
        date_obj = new Date(doc.timestamp)
        date = date_obj.toLocaleDateString()
        hour = date_obj.getHours()

        if not days[date]?
            days[date] = {}

        if not days[date][hour]?
            days[date][hour] = {}

        if doc.type == "breast_feeding"
            duration = get_duration_minutes(doc)
            if not days[date][hour][side]?
                days[date][hour][side] = duration
            else
                days[date][hour][side] += duration
        else if doc.type == "diaper_change"
            if not days[date][hour][doc.content]?
                days[date][hour][doc.content] = doc.count
            else
                days[date][hour][doc.content] += doc.count
        else if doc.type == "comment"
            if not days[date][hour]["comment"]?
                days[date][hour]["comment"] = doc.text
            else
                days[date][hour]["comment"] += "<br />" + doc.text

    for date, day of days
        for hour in [0..23]
            if not days[date][hour]?
                days[date][hour] = {}

    title: "Baby Tracker"
    content: templates.render("feeding_diaper_table.html", req, {})