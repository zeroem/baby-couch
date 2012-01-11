module.exports = [
    from: "/static/*"
    to: "static/*"
,
    from: "/"
    to: "_show/welcome"
,
    from: "/tracker/"
    to: "_show/tracker"
,
    from: "*"
    to: "_show/not_found"
]
