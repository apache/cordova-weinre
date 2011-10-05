
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre = require('../common/Weinre')

#-------------------------------------------------------------------------------
module.exports = class WiConsoleImpl

    constructor: ->
        @messagesEnabled = true

    #---------------------------------------------------------------------------
    setConsoleMessagesEnabled: (enabled, callback) ->
        oldValue = @messagesEnabled
        @messagesEnabled = enabled
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ oldValue ]

    #---------------------------------------------------------------------------
    clearConsoleMessages: (callback) ->
        Weinre.wi.ConsoleNotify.consoleMessagesCleared()
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, []

    #---------------------------------------------------------------------------
    setMonitoringXHREnabled: (enabled, callback) ->
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, []

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
