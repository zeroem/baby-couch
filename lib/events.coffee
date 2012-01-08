duality_events = require("duality/events")
session = require("session")

duality_events.on("updateFailure", (err, info, req, res, doc) ->
  alert err.message or err.toString()
)