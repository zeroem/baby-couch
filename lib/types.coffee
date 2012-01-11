Type   = require("couchtypes/types").Type
fields  = require("couchtypes/fields")
widgets = require("couchtypes/widgets")
validators = require("couchtypes/validators")

exports.comment = new Type "comment",
    fields:
        date: fields.number()
        text: fields.string
            widget: widgets.textarea({cols: 40, rows: 7})

exports.weight = new Type "weight",
    fields:
        date: fields.number()
        weight: fields.number
            validators: [ validators.min 0 ]

exports.length = new Type "length",
    fields:
        date: fields.number()
        length: fields.number
            validators: [ validators.min 0 ]

exports.bottle_feeding = new Type "bottle_feeding",
    fields:
        time: fields.number()
        type: fields.choice
            values: [
                ["formula", "Formula Milk"],
                ["human", "Human Milk"],
                ["other", "Other"]
            ]

exports.breast_feeding = new Type "breast_feeding",
    fields:
        startTime: fields.number()
        duration: fields.number()
        side: fields.choice
            values: [
                ["left", "Left Breast"],
                ["right", "Right Breast"]
            ]

exports.diaper_change = new Type "diaper_change",
    fields:
        time: fields.number()
        contents: fields.choice
            values: [
                ["wet", "Wet Diaper"],
                ["bm", "Soiled Diaper"],
                ["both", "Both"]
            ]

