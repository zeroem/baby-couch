module.exports = [
    from: "/static/*"
    to: "static/*"
,
    from: "/"
    to: "_show/tracker"
,
    from: "/chart"
    to: "_list/chart/timeline"
,
    from: "/tracker/"
    to: "_show/tracker"
,
    from: "/feeding/"
    to: "_show/feeding"
,
    from: "*"
    to: "_show/not_found"
]
