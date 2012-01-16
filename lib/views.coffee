exports.breast_feeding =
    map: (doc) ->
        if is_type doc, "breast_feeding"
            emit doc.timestamp, doc

exports.diaper_change =
    map: (doc) ->
        if is_type doc, "diaper_change"
            emit doc.timestamp, doc

exports.comment =
    map: (doc) ->
        if is_type doc, "comment"
            emit doc.timestamp, doc

exports.supplement =
    map: (doc) ->
        if is_type doc, "supplement"
            emit doc.timestamp, doc

is_type = (doc,type) ->
    doc.type? and doc.type == type