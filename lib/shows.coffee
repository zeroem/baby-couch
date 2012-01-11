templates = require "duality/templates"

exports.welcome = (doc, req) ->
    title: "It worked!"
    content: templates.render("welcome.html", req, {})

exports.tracker = (doc, req) ->
    title: "Baby Tracker"
    content: templates.render("tracker.html", req, {})

exports.not_found = (doc, req) ->
    code: 404
    title: "404 - Not Found"
    content: templates.render("404.html", req, {})
