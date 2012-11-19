
#---------------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
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
    Object.defineProperty Console, 'original',
        get: -> OriginalConsole

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
