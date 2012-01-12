exports.Timer = Timer = class
    elapsed: 0
    start_time: null

    reset: () ->
        @elapsed = 0;
        @start_time = null;

    start: () ->
        if @start_time == null then @start_time = new Date().getTime()

        @start_time

    stop: () ->
        if @start_time != null
            now = new Date().getTime()
            @elapsed += (now - @start_time)
            @start_time = null;
            now
        else
            false

    isStopped: () ->
        @start_time == null

    isRunning: () ->
        @start_time != null

    getElapsed: () ->
        if @start_time == null
            @elapsed
        else
            @elapsed + (new Date().getTime() - @start_time)

time_factors =
    ms: 1
    sec: 1000
    min: 1000 * 60
    hour: 1000 * 60 * 60
    order: ["hour","min","sec","ms"]

exports.elapsed = (ms,units) ->
    result = {}
    for factor in time_factors.order
        quantity = Math.floor(ms / time_factors[factor])
        result[factor] = quantity
        ms -= (quantity * time_factors[factor])

    result


exports.TimerUI = TimerUI = class
    _timer: new Timer()

    _startTimer: () ->
        if @_timer.isStopped()
            clearTimeout @_lastTimeout if @_lastTimeout?
            @_timer.start()
            @_updater() if @_updater?

    constructor: (options) ->
        opts = options || {}

        if opts.startButton?
            $(opts.startButton).click (event) =>
                @_startTimer()


        if opts.stopButton?
            $(opts.stopButton).click (event) =>
                @_timer.stop()

        if opts.resetButton?
            $(opts.resetButton).click (event) =>
                @_timer.reset()

        if opts.restartButton?
            $(opts.restartButton).click (event) =>
                @_timer.reset()
                @_startTimer()

        if opts.update
            @frequency = opts.frequency || 100
            @update = opts.update
            @_updater = () =>
                elapsed = exports.elapsed(@_timer.getElapsed())
                @update elapsed
                @_lastTimeout = setTimeout @_updater, @frequency if @_timer.isRunning()

        if opts.autostart? and opts.autostart
            @_startTimer()
