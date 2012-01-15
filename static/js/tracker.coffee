timer = require "utils/timer"
db = require "db"

te = null

$ () ->
    te = $ "#timer"
    init_timer()

    $("#left").click () ->
        pop_timer "left"

    $("#right").click () ->
        pop_timer "right"

pop_timer = (side) ->
    get_timer().reset()
    te.find("#side").val(side)

    $.colorbox
        inline: true
        href: "#timer"
        title: ucfirst(side) + " Breast"
        escKey: false
        overlayClose: false
        onComplete: () ->
            te.find("#start").focus()


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

        docs = []
        now = Date.now()
        msg = "Breast Feeding Saved"

        docs.push(breast_feeding now, get_side(), get_elapsed_time())

        if get_timer_comment().trim().length > 0
            docs.push(comment now, get_timer_comment())
            msg = "Breast Feeding and Comment Saved"

        db.current().bulkSave(docs, (err, resp) ->
            close_colorbox_flash_func msg
        )


get_elapsed_time = () ->
    Math.floor(get_timer().elapsed / 1000)

ucfirst = (str) ->
    str.substr(0,1).toUpperCase() + str.substr(1)

get_side = () ->
    te.find("#side").val()

get_timer = () ->
    te.data("timer_ui")._timer

get_timer_comment = () ->
    te.find("#comment").val()

close_colorbox_flash_func = (msg) ->
    (err, resp) ->
        $.colorbox.close()
        $("#flash").html(msg)

breast_feeding = (timestamp, side, duration) ->
    type: "breast_feeding"
    timestamp: timestamp
    side: side
    duration: duration

supplement = (timestamp,amount,supplement_type="formula") ->
    type: "supplement"
    timestamp: timestamp
    amount: amount
    supplement_type: supplement_type

diaper_change = (timestamp, type, count) ->
    type: "diaper_change"
    timestamp: timestamp
    count: count
    contents: type

comment = (timestamp, comment) ->
    type: "comment"
    timestamp: timestamp
    text: comment