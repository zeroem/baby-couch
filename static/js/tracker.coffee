timer = require "utils/timer"
db = require "db"
doc_template = require "lib/docs"


te = null

$ () ->
    te = $ "#timer"
    init_timer()
    init_comment()
    update_most_recent()

    #$("#left").click () ->
    #    pop_timer "left"

    #$("#right").click () ->
    #    pop_timer "right"

    $("#bm").click () ->
        save_document(doc_template.diaper_change(Date.now(),"bm",1))

    $("#wet").click () ->
        save_document(doc_template.diaper_change(Date.now(),"wet",1))

    $("[name=cancel]").click () ->



save_document = (doc) ->
    $.mobile.showPageLoadingMsg()
    db.current().saveDoc(doc, (err,resp) ->
        $.mobile.hidePageLoadingMsg()
        update_most_recent(true)
    )


<<<<<<< Updated upstream
pop_timer = (side) ->
    get_timer().reset()
    get_timer().run_ticker()
    te.find("#side").val(side)

    open_colorbox
        href: "#timer"
        title: ucfirst(side) + " Breast"
        onComplete: () ->
            te.find("#start").focus()

open_colorbox = (user) ->
    opts =
        inline: true
        overlayClose: false
        transition: "none"

    for own name, value of user
        opts[name] = value

    $.colorbox opts
=======
save_timer_state = () ->
    cookies.setBrowserCookie({},
        name: "timer_state"
        value: JSON.stringify(
            side: get_side()
            timer: te.data("timer_ui")._timer
        )
        path: "/"
        days: 1
    )

restore_timer_state = () ->
    obj = JSON.parse(unescape(cookies.readBrowserCookie("timer_state")))

    # and restore it's state
    _timer = get_timer()

    delete obj.timer._events

    for own key, value of obj.timer
        _timer[key] = value

    # the 'tick' event may not be running if we just reloaded the page
    # so, if we're in a 'running' state, make sure the ticker is also going
    #
    # need to figure out why this needs to be so complicated, I should be able
    # to just 'run_ticker' and be done with it
    if _timer.isRunning()
        _timer.stop()
        _timer.start()
    else
        _timer.run_ticker()

delete_timer_state = () ->
    cookies.setBrowserCookie {},
    name: "timer_state"
    value: ""
    path: "/"
    days: -2
>>>>>>> Stashed changes

init_timer = () ->
    te.data "timer_ui", new timer.TimerUI
        startButton: te.find "#start"
        stopButton:  te.find "#pause"
        resetButton: te.find "#reset"
        tick_rate:   50
        onTick: (timer) ->
            te.find("#display").html(get_timer().getElapsed().toString())
        onStart: () ->
            te.find("#pause").focus()
        onStop: () ->
            te.find("#start").focus()

    te.find("#timer_done").click () ->
        get_timer().stop() if get_timer().isRunning()
<<<<<<< Updated upstream
        save_document(doc_template.breast_feeding(Date.now(), get_side(), get_elapsed_time()))
        $.colorbox.close()
=======
        save_document(
            doc_template.breast_feeding(get_timer().stop_time, get_side(), get_elapsed_time()),
            (err,resp) ->
                delete_timer_state()
        )

>>>>>>> Stashed changes


init_comment = () ->
    $("#comment").click () ->
        $("#comment_text").val("")

    $("#comment_done").click () ->
        save_document(doc_template.comment(Date.now(), get_comment()))

get_elapsed_time = () ->
    Math.floor(get_timer().elapsed / 1000)

ucfirst = (str) ->
    str.substr(0,1).toUpperCase() + str.substr(1)

get_side = () ->
    te.find("#side").val()

get_timer = () ->
    te.data("timer_ui")._timer

get_comment = () ->
    $("#comment_text").val()


update_most_recent = (once=false) =>
    db.current().getView("baby-couch","most_recent",{}, (err,resp) ->
        text = ""
        for type, doc of resp.rows[0].value
            text += "<li>" + snippet(doc) + "</li>"

        $("#most_recent_content").html(text);

        if not once
            setTimeout update_most_recent, 60000
    )


snippet = (doc) ->
    message = ""

    if doc.type == "breast_feeding"
        message = "Feeding"

        if side == "left"
            message += "(L)"
        else
            message += "(R)"

        message += ": " + age(doc.timestamp)
    else if doc.type="diaper_change"
        message = "Change: " + age(doc.timestamp)

    message


age = (timestamp) ->
    elapsed = new timer.Elapsed(Date.now() - timestamp)
    time = ""

    if elapsed.hour > 24
        days = Math.floor(elapsed.hour/24) + "."
        remainder = elapsed.hour % 24

        if remainder > 18
            days++
        else if remainder > 8
            days += .5

        time = days + " days"
    else if elapsed.hour > 0
        hours = elapsed.hour
        if hours < 6
            if elapsed.min > 50
                hours++
            else if elapsed.min > 20
                hours += .5
        time = hours + " hours"
    else if elapsed.min >= 15
        time = (Math.floor(elapsed.min/15) * 15) + " minutes"
    else
        time = "< 15 minutes"

    time += " ago"
