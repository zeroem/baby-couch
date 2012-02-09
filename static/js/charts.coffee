called = null
$ () ->

    if not called?
        called = true
        db = require("db").current()

        db.getView "baby-couch", "timeline",
            startkey: (Date.now() - (7*24 * 60 * 60 * 1000)),
            (err, resp) ->
                if not err
                    width="100%"
                    height="100%"

                    x = d3.scale.linear().domain(resp.rows[0].key, resp.rows[resp.rows.length-1].key)
