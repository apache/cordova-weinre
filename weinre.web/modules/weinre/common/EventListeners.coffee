
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Ex     = require('./Ex')
Weinre = require('./Weinre')

#-------------------------------------------------------------------------------
module.exports = class EventListeners

    constructor: ->
        @listeners = []

    #---------------------------------------------------------------------------
    add: (listener, useCapture) ->
        @listeners.push [ listener, useCapture ]

    #---------------------------------------------------------------------------
    remove: (listener, useCapture) ->
        listeners = @listeners.slice()

        for _listener in listeners
            continue unless _listener[0] == listener
            continue unless _listener[1] == useCapture

            @_listeners.splice i, 1
            return

    #---------------------------------------------------------------------------
    fire: (event) ->
        listeners = @listeners.slice()
        for listener in listeners
            listener = listener[0]

            if typeof listener is "function"
                try
                    listener.call null, event
                catch e
                    Weinre.logError "#{arguments.callee.name} invocation exception: #{e}"
                continue

            if typeof listener?.handleEvent isnt "function"
                throw new Ex(arguments, "listener does not implement the handleEvent() method")

            try
                listener.handleEvent.call listener, event
            catch e
                Weinre.logError "#{arguments.callee.name} invocation exception: #{e}"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)

