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
