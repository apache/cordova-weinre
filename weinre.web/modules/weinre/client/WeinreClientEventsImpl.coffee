
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Callback                    = require('../common/Callback')
Weinre                      = require('../common/Weinre')

WeinreExtraTargetEventsImpl = require('./WeinreExtraTargetEventsImpl')

titleNotConnected    = "weinre: target not connected"
titleConnectedPrefix = "weinre: "

document.title = titleNotConnected

#-------------------------------------------------------------------------------
module.exports = class WeinreClientEventsImpl

    constructor: (client) ->
        @client = client

    #---------------------------------------------------------------------------
    clientRegistered: (clientDescription) ->
        WebInspector.panels.remote.addClient clientDescription if @client.uiAvailable()

    #---------------------------------------------------------------------------
    targetRegistered: (targetDescription) ->
        WebInspector.panels.remote.addTarget targetDescription if @client.uiAvailable()
        return unless Weinre.client.autoConnect()
        return unless Weinre.messageDispatcher

        Weinre.WeinreClientCommands.connectTarget Weinre.messageDispatcher.channel, targetDescription.channel

    #---------------------------------------------------------------------------
    clientUnregistered: (clientChannel) ->
        WebInspector.panels.remote.removeClient clientChannel if @client.uiAvailable()

    #---------------------------------------------------------------------------
    targetUnregistered: (targetChannel) ->
        WebInspector.panels.remote.removeTarget targetChannel if @client.uiAvailable()

    #---------------------------------------------------------------------------
    connectionCreated: (clientChannel, targetChannel) ->
        if @client.uiAvailable()
            WebInspector.panels.remote.setClientState clientChannel, "connected"
            WebInspector.panels.remote.setTargetState targetChannel, "connected"

        return unless clientChannel == Weinre.messageDispatcher.channel

        WebInspector.panels.elements.reset()
        WebInspector.panels.timeline._clearPanel()
        WebInspector.panels.resources.reset()

        target = WebInspector.panels.remote.getTarget(targetChannel)
        document.title = titleConnectedPrefix + target.url
        WebInspector.inspectedURLChanged target.url

        Weinre.WeinreExtraClientCommands.getDatabases (databaseRecords) ->
            WeinreExtraTargetEventsImpl.addDatabaseRecords databaseRecords

    #---------------------------------------------------------------------------
    connectionDestroyed: (clientChannel, targetChannel) ->
        if @client.uiAvailable()
            WebInspector.panels.remote.setClientState clientChannel, "not-connected"
            WebInspector.panels.remote.setTargetState targetChannel, "not-connected"

        return unless clientChannel == Weinre.messageDispatcher.channel

        document.title = titleNotConnected
        return unless Weinre.client.autoConnect()
        return unless @client.uiAvailable()

        nextTargetChannel = WebInspector.panels.remote.getNewestTargetChannel(targetChannel)
        return unless nextTargetChannel

        Weinre.WeinreClientCommands.connectTarget Weinre.messageDispatcher.channel, nextTargetChannel
        Weinre.logInfo "autoconnecting to " + nextTargetChannel

    #---------------------------------------------------------------------------
    sendCallback: (callbackId, result) ->
        Callback.invoke callbackId, result

    #---------------------------------------------------------------------------
    serverProperties: (properties) ->
        WebInspector.panels.remote.setServerProperties properties if @client.uiAvailable()

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
