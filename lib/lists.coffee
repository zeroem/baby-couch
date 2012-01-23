templates = require "duality/templates"

exports.chart = (head,req) ->
    start
        headers:
            "Content-Type": "text/html"

    class Day
        date: null
        hours: []

    class Hour
        hour: 0
        left: 0
        right: 0
        wet: 0
        bm: 0
        supplement: 0

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
                days[date][hour]["comment"] = []

            days[date][hour]["comment"].push doc.text

    exp_days = []

    for date, day of days
        day_obj = new Day()
        day_obj.date = date
        for hour in [0..23]
            hour_obj = new Hour()
            hour_obj.hour = hour

            if day[hour]?
                hour_obj.wet = day[hour].wet
                hour_obj.bm = day[hour].bm
                hour_obj.left = day[hour].left
                hour_obj.right = day[hour].right
                hour_obj.comments = day[hour].comment

            day_obj.hours.push hour_obj
        exp_days.push day_obj

    title: "Hospital Chart"
    content: templates.render("feeding_diaper_table.html", req, {days:exp_days})