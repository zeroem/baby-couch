exports.breast_feeding = (timestamp, side, duration) ->
    type: "breast_feeding"
    timestamp: timestamp
    side: side
    duration: duration

exports.supplement = (timestamp,amount,supplement_type="formula") ->
    type: "supplement"
    timestamp: timestamp
    amount: amount
    supplement_type: supplement_type

exports.diaper_change = (timestamp, type, count) ->
    type: "diaper_change"
    timestamp: timestamp
    count: count
    contents: type

exports.comment = (timestamp, comment) ->
    type: "comment"
    timestamp: timestamp
    text: comment