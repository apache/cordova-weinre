
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre   = require('../common/Weinre')
Callback = require('../common/Callback')
Console  = require('./Console')

#-------------------------------------------------------------------------------
module.exports = class WeinreTargetEventsImpl

    constructor: ->

    #---------------------------------------------------------------------------
    connectionCreated: (clientChannel, targetChannel) ->
        message = "weinre: target #{targetChannel} connected to client " + clientChannel
        Weinre.logInfo message

        oldValue = Console.useRemote(true)
        Weinre.target.setDocument()
        Weinre.wi.TimelineNotify.timelineProfilerWasStopped()
        Weinre.wi.DOMStorage.initialize()

    #---------------------------------------------------------------------------
    connectionDestroyed: (clientChannel, targetChannel) ->
        message = "weinre: target #{targetChannel} disconnected from client " + clientChannel
        Weinre.logInfo message

        oldValue = Console.useRemote(false)

    #---------------------------------------------------------------------------
    sendCallback: (callbackId, result) ->
        Callback.invoke callbackId, result

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
