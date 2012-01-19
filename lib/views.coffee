
exports.breast_feeding =
    map: (doc) ->
        if doc.type == "breast_feeding"
            emit doc.timestamp, doc

exports.diaper_change =
    map: (doc) ->
        if doc.type == "diaper_change"
            emit doc.timestamp, doc

exports.comment =
    map: (doc) ->
        if doc.type == "comment"
            emit doc.timestamp, doc

exports.supplement =
    map: (doc) ->
        if doc.type == "supplement"
            emit doc.timestamp, doc

exports.timeline =
    map: (doc) ->
        if doc.type?
            emit doc.timestamp, doc

exports.most_recent =
    map: (doc) ->
        most_recent_list =
            "breast_feeding": null
            "diaper_change": null

        if most_recent_list.hasOwnProperty doc.type
            emit doc.timestamp, doc

    reduce: (keys, values, rereduce) ->
        result = {}

        process = (doc,result) ->
            type = doc.type

            if not result[type]?
                result[type] = doc
            else
                if doc.timestamp > result[type].timestamp
                    result[type] = doc
            result

        if not rereduce
            for doc in values
                result = process(doc,result)
        else
            for reduced in values
                for type, doc of reduced
                    result = process(doc, result)
        result