
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Ex        = require('../common/Ex')
HookSites = require('./HookSites')

#-------------------------------------------------------------------------------
module.exports = class ExceptionalCallbacks

    @addHooks: ->
        addHookTimer HookSites.window_setInterval, callSite_setInterval
        addHookTimer HookSites.window_setTimeout,  callSite_setTimeout

        addHookEventListener HookSites.window_addEventListener,         callSite_windowAEL
        addHookEventListener HookSites.Node_addEventListener,           callSite_nodeAEL
        addHookEventListener HookSites.XMLHttpRequest_addEventListener, callSite_xhrAEL

#-------------------------------------------------------------------------------
addHookTimer = (hookSite, formatter) ->
    hookSite.addHooks
        before:  (receiver, args) ->
            code = args[0]
            return unless typeof(code) is "function"

            millis   = args[1]
            callSite = formatter(millis, code)

            args[0] = instrumentedCallback(code, callSite)

#-------------------------------------------------------------------------------
addHookEventListener = (hookSite, formatter) ->
    hookSite.addHooks
        before:  (receiver, args) ->
            code = args[1]
            return unless typeof(code) is "function"

            event    = args[0]
            callSite = formatter(event, code, receiver)

            args[1] = instrumentedCallback(code, callSite)

#-------------------------------------------------------------------------------
instrumentedCallback = (code, callSite) ->
    return code unless typeof(code) is "function"

    instrumentedCode = ->
        try
            return code.apply(this, arguments)
        catch e
            console.log "exception in callback: #{e}"
            console.log "  callsite: #{callSite}"

            if e.stack
                console.log "stack at time of exception:"
                console.log e.stack

            throw e

    instrumentedCode

#-------------------------------------------------------------------------------
callSite_setTimeout = (time, func) ->
    "setTimeout(#{getFunctionName(func)}, #{time})"

#-------------------------------------------------------------------------------
callSite_setInterval = (time, func) ->
    "setInterval(#{getFunctionName(func)}, #{time})"

#-------------------------------------------------------------------------------
callSite_windowAEL = (event, func) ->
    "window.addEventListener('#{event}', #{getFunctionName(func)})"

#-------------------------------------------------------------------------------
callSite_nodeAEL = (event, func, node) ->
    node = node.nodeName if node.nodeName
    "#{node}.addEventListener('#{event}', #{getFunctionName(func)})"

#-------------------------------------------------------------------------------
callSite_xhrAEL = (event, func) ->
    "XMLHttpRequest.addEventListener('#{event}', #{getFunctionName(func)})"

#-------------------------------------------------------------------------------
getFunctionName = (func) ->
    return func.displayName if func.displayName
    return func.name if func.name
    return '<anonymous>'

#-------------------------------------------------------------------------------
getStackTrace = (e) ->
    return e.stack if e.stack

    return null

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)