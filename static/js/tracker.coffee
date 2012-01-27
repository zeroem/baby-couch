timer = require "utils/timer"
db = require "db"
doc_template = require "lib/docs"
last_document = null
undo_timeout = null
templates = require "duality/templates"
cookies = require "cookies"

te = null

$ () ->
    te = $ "#timer"
    init_timer()
    init_comment()
    init_supplement()
    update_most_recent()

    $("[name=feeding]").click (event) ->
        $("#side").val(event.delegateTarget.id)

    $("#bm").click () ->
        save_document(doc_template.diaper_change(Date.now(),"bm",1))

    $("#wet").click () ->
        save_document(doc_template.diaper_change(Date.now(),"wet",1))

    $("[name=cancel]").click () ->


    $("#timer [name=cancel]").click () ->
        delete_timer_state()

    $("[name=undo]").click () ->
        if last_document?
            $.mobile.showPageLoadingMsg()
            db.current().removeDoc(last_document, (err, resp)->
                $.mobile.hidePageLoadingMsg()
                if not err?
                    clear_undo()
                    update_most_recent()
            )

    $("[name=back]").click () ->
        clear_undo()

    if cookies.readBrowserCookie("timer_state")?
        restore_timer_state()


init_supplement = () ->
    form = $ "#supplement_form"
    form.find("[name=save]").click () ->
        amount = parseInt(form.find("#supplement_amount").val())
        type = form.find("#supplement_type").val()
        if amount and amount > 0
            save_document(
                doc_template.supplement(
                    Date.now(),
                    amount,
                    type
                ),
                (err,resp) ->
                    amount.val("")
            )

clear_undo = () ->
    last_document = null
    undo_timeout = null
    $("[name=undo]").hide()

save_document = (doc,fn=null) ->
    $.mobile.showPageLoadingMsg()
    db.current().saveDoc(doc, (err,resp) ->
        $.mobile.hidePageLoadingMsg()
        if not err?
            update_most_recent(true)
            last_document =
                _id: resp.id
                _rev: resp.rev

            $("[name=undo]").show()
            clearTimeout undo_timeout if undo_timeout?

            undo_timeout = setTimeout(clear_undo, 30*1000)
        else
            # do something with the error?

        if $.isFunction fn
            fn(err,resp)
    )


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

    $("#side").val(obj.side)

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


init_timer = () ->

    ui = new timer.TimerUI
        startButton: te.find "#start"
        stopButton:  te.find "#pause"
        resetButton: te.find "#reset"
        tick_rate:   200
        onTick: (timer) ->
            te.find("#display").html(get_timer().getElapsed().displayMinutesAndSeconds())
        onStart: () ->
            te.find("#start").hide()
            te.find("#pause").show()
            save_timer_state()
        onStop: () ->
            te.find("#pause").hide()
            te.find("#start").show()
            save_timer_state()


    te.data "timer_ui", ui

    te.find("#timer_done").click () ->
        get_timer().stop() if get_timer().isRunning()
        if get_elapsed_time() > 0
            save_document(
                doc_template.breast_feeding(get_timer().stop_time, get_side(), get_elapsed_time()),
                (err,resp) ->
                    delete_timer_state()
                    get_timer().reset()
            )

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
