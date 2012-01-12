exports.import = (path) ->
    require "d3" if not d3?
    require "d3.csv" if not d3.csv?

    d3.csv path, (rows) ->
        db = require "db"
        docs = []

        for row in rows
            timestamp = new Date(row.Timestamp).getTime()

            if row.Left
                docs.push breast_feeding timestamp, "left", minutes_to_seconds row.Left

            if row.Right
                docs.push breast_feeding timestamp, "left", minutes_to_seconds row.Right

            if row.Supplement
                type = "formula"
                if row.Comment and row.Comment.toLowerCase().indexOf("breast") != -1
                    type = "human"
                docs.push supplement timestamp, row.Supplement, type

            if row.BM
                docs.push diaper_change timestamp, "bm", row.BM

            if row.Wet
                docs.push diaper_change timestamp, "wet", row.BM

            if row.Comment
                docs.push comment timestamp, row.Comment

        db.current().bulkSave docs, console.log

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
    mins * 60