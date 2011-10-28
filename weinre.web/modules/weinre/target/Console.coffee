
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre   = require('../common/Weinre')
Timeline = require('../target/Timeline')

UsingRemote = false

RemoteConsole   = null
OriginalConsole = null

MessageSource =
    HTML:  0
    WML:   1
    XML:   2
    JS:    3
    CSS:   4
    Other: 5

MessageType =
    Log:                 0
    Object:              1
    Trace:               2
    StartGroup:          3
    StartGroupCollapsed: 4
    EndGroup:            5
    Assert:              6
    UncaughtException:   7
    Result:              8

MessageLevel =
    Tip:     0
    Log:     1
    Warning: 2
    Error:   3
    Debug:   4

#-------------------------------------------------------------------------------
module.exports = class Console

    #---------------------------------------------------------------------------
    Console::__defineGetter__("original", -> OriginalConsole)

    #---------------------------------------------------------------------------
    @useRemote: (value) ->
        return UsingRemote if arguments.length == 0

        oldValue = UsingRemote
        UsingRemote = not not value

        if UsingRemote
            window.console = RemoteConsole
        else
            window.console = OriginalConsole

        oldValue

    #---------------------------------------------------------------------------
    _generic: (level, messageParts) ->
        message = messageParts[0].toString()
        parameters = []

        for messagePart in messageParts
            parameters.push Weinre.injectedScript.wrapObjectForConsole(messagePart, true)

        payload =
            source: MessageSource.JS
            type: MessageType.Log
            level: level
            message: message
            parameters: parameters

        Weinre.wi.ConsoleNotify.addConsoleMessage payload

    #---------------------------------------------------------------------------
    log: ->
        @_generic MessageLevel.Log, [].slice.call(arguments)

    #---------------------------------------------------------------------------
    debug: ->
        @_generic MessageLevel.Debug, [].slice.call(arguments)

    #---------------------------------------------------------------------------
    error: ->
        @_generic MessageLevel.Error, [].slice.call(arguments)

    #---------------------------------------------------------------------------
    info: ->
        @_generic MessageLevel.Log, [].slice.call(arguments)

    #---------------------------------------------------------------------------
    warn: ->
        @_generic MessageLevel.Warning, [].slice.call(arguments)

    #---------------------------------------------------------------------------
    dir: ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    dirxml: ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    trace: ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    assert: (condition) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    count: ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    markTimeline: (message) ->
        Timeline.addRecord_Mark message

    #---------------------------------------------------------------------------
    lastWMLErrorMessage: ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    profile: (title) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    profileEnd: (title) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    time: (title) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    timeEnd: (title) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    group: ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    groupCollapsed: ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    groupEnd: ->
        Weinre.notImplemented arguments.callee.signature

#-------------------------------------------------------------------------------
RemoteConsole   = new Console()
OriginalConsole = window.console

RemoteConsole.__original   = OriginalConsole
OriginalConsole.__original = OriginalConsole

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
