templates = require "duality/templates"
timer = require "utils/timer"

exports.welcome = (doc, req) ->
    title: "It worked!"
    content: templates.render("welcome.html", req, {})

exports.tracker = (doc, req) ->
    data =
        title: "Baby Tracker"

    data.content = templates.render("tracker.html", req, data)

    data

exports.feeding = (doc, req) ->
    content = templates.render("timer.html", req, {})

    if req.client
        $.colorbox(html: content)
        $("#timer").TimerUI = new timer.TimerUI
            startButton: "#timer #start"
            stopButton:  "#timer #pause"
            restartButton: "#timer #restart"
            resetButton: "#timer #reset"
            tick_rate:   freq
            onTick: (timer) ->
                $("#timer #display").html(timer.getElapsed().toString())
            onStart: () =>
                $("#timer #pause").focus()
                $("#timer #restart").show()
            onStop: () =>
                $("#timer #start").focus()
                $("#timer #restart").hide()
    else
        title: "Breast Feeding"
        content: content

exports.not_found = (doc, req) ->
    code: 404
    title: "404 - Not Found"
    content: templates.render("404.html", req, {})
