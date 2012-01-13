events = require "events"

exports.Timer = class Timer extends events.EventEmitter
    elapsed: 0
    start_time: null
    tick_rate: 100

    constructor: (@tick_rate=100) ->
        super()

    run_ticker: () =>
        @emit "tick", @

        if @isRunning()
            @_lastTick = setTimeout(@run_ticker,@tick_rate)

    # not sure if this should trigger a "stop" event, or it's own "reset" event
    reset: () ->
        @elapsed = 0;
        @start_time = null;

    start: () ->
        if @start_time == null
            @start_time = new Date().getTime()
            @emit "start", @
            @run_ticker()

        @start_time

    stop: () ->
        if @start_time != null
            now = new Date().getTime()
            @elapsed += (now - @start_time)
            @start_time = null;
            @emit "stop", @
            now
        else
            false

    isStopped: () ->
        @start_time == null

    isRunning: () ->
        @start_time != null

    getElapsed: () ->
        if @isStopped()
            new Elapsed @elapsed
        else
            new Elapsed(@elapsed + (new Date().getTime() - @start_time))



exports.Elapsed = class Elapsed
    @_time_factors:
        ms: 1
        sec: 1000
        min: 1000 * 60
        hour: 1000 * 60 * 60
        order: ["hour","min","sec","ms"]

    constructor: (ms) ->
        for name in Elapsed._time_factors.order
            factor = Elapsed._time_factors[name]
            quantity = Math.floor(ms / factor)
            @[name] = quantity
            ms -= (quantity * factor)

    _pad: (value,digits=2) ->
        check = Math.pow(10,digits-1)
        result = ""

        if (value / check) < 1
            while (value / check) < 1 and check > 1
                result += "0"
                check /= 10
            result += Math.floor value
        else
            while (value / check) >= 10
                value /= 10

            result = "" + Math.floor value

    _trunc: (value,digits=2) ->
        Math.floor(value / Math.pow(10, digits))

    toString: () ->
        [@_pad(@hour),@_pad(@min),@_pad(@sec)].join(":") + "." + @_trunc(@ms)


exports.TimerUI = class TimerUI
    constructor: (@options = {}) ->
        @_timer = new Timer(@options.tick_rate || 50)

        if @options.onStart? then @_timer.on "start", @options.onStart
        if @options.onStop? then @_timer.on "stop", @options.onStop
        if @options.onTick? then @_timer.on "tick", @options.onTick

        if @options.startButton?
            $(@options.startButton).click (event) =>
                @_timer.start()

        if @options.stopButton?
            $(@options.stopButton).click (event) =>
                @_timer.stop()

        if @options.resetButton?
            $(@options.resetButton).click (event) =>
                @_timer.reset()

        if @options.restartButton?
            $(@options.restartButton).click (event) =>
                @_timer.reset()
                @_timer.start()

        if @options.autostart? and @options.autostart
            @_timer.start()


exports.test = (freq = 1000) ->
    new TimerUI
        startButton: "#start"
        stopButton:  "#pause"
        restartButton: "#restart"
        resetButton: "#reset"
        tick_rate:   freq
        onTick: (timer) ->
            $("#display").html(timer.getElapsed().toString())
        onStart: () =>
            $("#pause").focus()
            $("#restart").show()
        onStop: () =>
            $("#start").focus()
            $("#restart").hide()

