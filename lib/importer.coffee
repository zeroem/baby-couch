exports.import = (path) ->
    require "d3" if not d3?
    require "d3.csv" if not d3.csv?

    d3.csv path, (rows) ->
        db = require "db"
        docs = []

        for row in rows
            timestamp = new Date(row.Timestamp).getTime()

            if row.Left.length
                sec = minutes_to_seconds row.Left
                if sec > 0 then docs.push breast_feeding timestamp, "left", sec

            if row.Right.length
                sec = minutes_to_seconds row.Right
                if sec > 0 then docs.push breast_feeding timestamp, "right", sec

            if row.Supplement.length
                type = "formula"
                if row.Comment and row.Comment.toLowerCase().indexOf("breast") != -1
                    type = "human"
                amount = parseFloat row.Supplement

                if amount > 0 then docs.push supplement timestamp, amount, type

            if row.BM.length then docs.push diaper_change timestamp, "bm", parseInt row.BM

            if row.Wet.length then docs.push diaper_change timestamp, "wet", parseInt row.Wet

            if row.Comment.length then docs.push comment timestamp, row.Comment

        db.current().bulkSave docs, {all_or_nothing: true}, (err,resp) ->
            console.log err

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

minutes_to_seconds = (mins) ->
    parseFloat(mins) * 60