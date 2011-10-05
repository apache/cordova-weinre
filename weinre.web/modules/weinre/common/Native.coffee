
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

exports.original = {}

exports.original.clearInterval             = window.clearInterval
exports.original.clearTimeout              = window.clearTimeout
exports.original.setTimeout                = window.setTimeout
exports.original.setInterval               = window.setInterval
exports.original.XMLHttpRequest            = window.XMLHttpRequest
exports.original.XMLHttpRequest_open       = window.XMLHttpRequest.prototype.open
exports.original.LocalStorage_setItem      = window.localStorage?.setItem
exports.original.LocalStorage_removeItem   = window.localStorage?.removeItem
exports.original.LocalStorage_clear        = window.localStorage?.clear
exports.original.SessionStorage_setItem    = window.sessionStorage?.setItem
exports.original.SessionStorage_removeItem = window.sessionStorage?.removeItem
exports.original.SessionStorage_clear      = window.sessionStorage?.clear
exports.original.openDatabase              = window.openDatabase

exports.clearInterval             = -> exports.original.clearInterval.apply( window, [].slice.call(arguments))
exports.clearTimeout              = -> exports.original.clearTimeout.apply(  window, [].slice.call(arguments))
exports.setInterval               = -> exports.original.setInterval.apply(   window, [].slice.call(arguments))
exports.setTimeout                = -> exports.original.setTimeout.apply(    window, [].slice.call(arguments))
exports.XMLHttpRequest            = -> new exports.original.XMLHttpRequest()
exports.XMLHttpRequest_open       = -> exports.original.XMLHttpRequest_open.apply(this, [].slice.call(arguments))
exports.LocalStorage_setItem      = -> exports.original.LocalStorage_setItem.apply(      window.localStorage,   [].slice.call(arguments))
exports.LocalStorage_removeItem   = -> exports.original.LocalStorage_removeItem.apply(   window.localStorage,   [].slice.call(arguments))
exports.LocalStorage_clear        = -> exports.original.LocalStorage_clear.apply(        window.localStorage,   [].slice.call(arguments))
exports.SessionStorage_setItem    = -> exports.original.SessionStorage_setItem.apply(    window.sessionStorage, [].slice.call(arguments))
exports.SessionStorage_removeItem = -> exports.original.SessionStorage_removeItem.apply( window.sessionStorage, [].slice.call(arguments))
exports.SessionStorage_clear      = -> exports.original.SessionStorage_clear.apply(      window.sessionStorage, [].slice.call(arguments))
exports.openDatabase              = -> exports.original.openDatabase.apply(              window,                [].slice.call(arguments))

for own key, val of exports
    if typeof(val) is "function"
        val.signature   = "Native::#{key}"
        val.displayName = key
        val.name        = key
