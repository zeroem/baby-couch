timer = require "utils/timer"
db = require "db"
doc_template = require "lib/docs"
last_document = null
templates = require "duality/templates"

te = null

$ () ->
    te = $ "#timer"
    init_timer()
    init_comment()
    update_most_recent()

    $("#left").click () ->
        pop_timer "left"

    $("#right").click () ->
        pop_timer "right"

    $("#bm").click () ->
        save_document(doc_template.diaper_change(Date.now(),"bm",1))

    $("#wet").click () ->
        save_document(doc_template.diaper_change(Date.now(),"wet",1))

    $("[name=cancel]").click () ->
        $.colorbox.close()

    $("#undo").click () ->
        console.log "here"
        if last_document?
            $.mobile.showPageLoadingMsg()
            db.current().removeDoc(last_document, (err, resp)->
                $.mobile.hidePageLoadingMsg()
                if not err?
                    clear_undo()
                    update_most_recent()
            )


clear_undo = () ->
    last_document = null
    $("#undo").hide()

save_document = (doc) ->
    $.mobile.showPageLoadingMsg()
    db.current().saveDoc(doc, (err,resp) ->
        $.mobile.hidePageLoadingMsg()

        if not err?
            update_most_recent(true)
            last_document =
                _id: resp.id
                _rev: resp.rev

            $("#undo").show()
            setTimeout(clear_undo, 30*1000)
        else
            # do something with the error?
    )


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
        save_document(doc_template.breast_feeding(get_timer().stop_time, get_side(), get_elapsed_time()))
        $.colorbox.close()


init_comment = () ->
    $("#comment").click () ->
        $("#comment_text").val("")

        open_colorbox
            title: "Comments"
            href:  "#comment_form"

    $("#comment_done").click () ->
        save_document(doc_template.comment(Date.now(), get_comment()))
        $.colorbox.close()

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

        if not err?
            data =
                items: []

            for type, doc of resp.rows[0].value
                data.items.push(snippet(doc))

            $("#most_recent_content").html(templates.render("most_recent.html",{},data));
        else
            # do something with the error?

        if not once
            setTimeout update_most_recent, 60000
    )


snippet = (doc) ->
    message = ""

    if doc.type == "breast_feeding"
        message = "Feeding"

        if doc.side == "left"
            message += "(L)"
        else
            message += "(R)"

        message += ": " + age(doc.timestamp)
    else if doc.type="diaper_change"
        if doc.contents == "bm"
            message = "Poops: " + age(doc.timestamp)
        else if doc.contents == "wet"
            message = "Peeps: " + age(doc.timestamp)
        else
            message = "error"

    message


age = (timestamp) ->
    elapsed = new timer.Elapsed(Date.now() - timestamp)
    time = ""

    if elapsed.hour > 24
        days = Math.floor(elapsed.hour/24)
        remainder = elapsed.hour % 24

        if remainder > 18
            days++
        else if remainder > 8
            days += .5

        time = days + "d"
    else if elapsed.hour > 0
        hours = elapsed.hour
        if hours < 6
            if elapsed.min > 50
                hours++
            else if elapsed.min > 20
                hours += .5
        time = hours + "h"
    else
        time = elapsed.min + "m"

    time
