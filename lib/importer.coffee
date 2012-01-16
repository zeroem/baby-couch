doc_template = require "lib/docs"

exports.import = (path) ->
    require "d3" if not d3?
    require "d3.csv" if not d3.csv?

    d3.csv path, (rows) ->
        db = require "db"
        docs = []

        for row in rows
            timestamp = new Date(row.Timestamp).getTime()

            if row.Left.length
                sec = minutes_to_seconds(row.Left)
                if sec > 0
                    docs.push(doc_template.breast_feeding(timestamp, "left", sec))

            if row.Right.length
                sec = minutes_to_seconds(row.Right)
                if sec > 0
                    docs.push(doc_template.breast_feeding(timestamp, "right", sec))

            if row.Supplement.length
                type = "formula"
                if row.Comment and row.Comment.toLowerCase().indexOf("breast") != -1
                    type = "human"
                amount = parseFloat(row.Supplement)

                if amount > 0
                    docs.push(doc_template.supplement(timestamp, amount, type))

            if row.BM.length
                docs.push(doc_template.diaper_change(timestamp, "bm", parseInt row.BM))

            if row.Wet.length
                docs.push(doc_template.diaper_change(timestamp, "wet", parseInt row.Wet))

            if row.Comments.length
                docs.push(doc_template.comment(timestamp, row.Comments))

        db.current().bulkSave docs, {all_or_nothing: true}, (err,resp) ->
            console.log err



minutes_to_seconds = (mins) ->
    parseFloat(mins) * 60