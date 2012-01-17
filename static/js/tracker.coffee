timer = require "utils/timer"
db = require "db"
doc_template = require "lib/docs"

te = null

$ () ->
    te = $ "#timer"
    init_timer()
    init_comment()

    $("#left").click () ->
        pop_timer "left"

    $("#right").click () ->
        pop_timer "right"

    $("#bm").click () ->
        db.current().saveDoc(doc_template.diaper_change(Date.now(),"bm",1), (err,resp) ->
            flash("Poops Saved")
        )

    $("#wet").click () ->
        db.current().saveDoc(doc_template.diaper_change(Date.now(),"wet",1), (err,resp) ->
            flash("Peeps Saved")
        )

    $("[name=cancel]").click () ->
        $.colorbox.close()

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

        db.current().saveDoc(
            doc_template.breast_feeding(Date.now(), get_side(), get_elapsed_time()),
            close_colorbox_flash_func "Feeding Saved"
        )

init_comment = () ->
    $("#comment").click () ->
        $("#comment_text").val("")

        open_colorbox
            title: "Comments"
            href:  "#comment_form"

    $("#comment_done").click () ->
        db.current().saveDoc(
            doc_template.comment(Date.now(), get_comment()), close_colorbox_flash_func "Comment Saved"
        )

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

close_colorbox_flash_func = (msg) ->
    (err, resp) ->
        $.colorbox.close()
        flash(msg)

flash = (msg,good=true) ->
    flash_element = $("#flash")
    flash_element.html(msg)

    if good
        flash_element.addClass "good"
        flash_element.removeClass "bad"
    else
        flash_element.addClass "bad"
        flash_element.removeClass "good"
