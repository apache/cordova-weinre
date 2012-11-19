# a place for browser specific hacks


BrowserHacks = ->

    # check for quirks mode
    if typeof document.addEventListener is "undefined"
        alert "Oops. It seems the page runs in compatibility mode. Please fix it and try again."
        return

    if typeof (window.Element) is "undefined"
        window.Element = ->

    if typeof (window.Node) is "undefined"
        window.Node = ->

    unless Object.getPrototypeOf
        Object.getPrototypeOf = (object) ->
            throw new Error("This vm does not support __proto__ and getPrototypeOf. Script requires any of them to operate correctly.")  unless object.__proto__
            object.__proto__
        return

BrowserHacks()