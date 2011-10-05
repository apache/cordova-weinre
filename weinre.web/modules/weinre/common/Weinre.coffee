
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Ex         = require('./Ex')
IDLTools   = require('./IDLTools')
StackTrace = require('./StackTrace')

_notImplemented     = {}
_showNotImplemented = false
CSSProperties       = []
logger              = null

#-------------------------------------------------------------------------------
module.exports = class Weinre

    #---------------------------------------------------------------------------
    constructor: ->
        throw new Ex(arguments, "this class is not intended to be instantiated")

    #---------------------------------------------------------------------------
    @addIDLs: (idls) ->
        IDLTools.addIDLs idls

    #---------------------------------------------------------------------------
    @addCSSProperties: (cssProperties) ->
        CSSProperties = cssProperties

    #---------------------------------------------------------------------------
    @getCSSProperties: ->
        CSSProperties

    #---------------------------------------------------------------------------
    @deprecated: () ->
        StackTrace.dump arguments

    #---------------------------------------------------------------------------
    @notImplemented: (thing) ->
        return if _notImplemented[thing]

        _notImplemented[thing] = true
        return unless _showNotImplemented

        Weinre.logWarning thing + " not implemented"

    #---------------------------------------------------------------------------
    @showNotImplemented: () ->
        _showNotImplemented = true

        for key of _notImplemented
            Weinre.logWarning key + " not implemented"

    #---------------------------------------------------------------------------
    @logError: (message) ->
        getLogger().logError message

    #---------------------------------------------------------------------------
    @logWarning: (message) ->
        getLogger().logWarning message

    #---------------------------------------------------------------------------
    @logInfo: (message) ->
        getLogger().logInfo message

    #---------------------------------------------------------------------------
    @logDebug: (message) ->
        getLogger().logDebug message

#-------------------------------------------------------------------------------
class ConsoleLogger
    logError:   (message) -> console.log "error: #{message}"
    logWarning: (message) -> console.log "warning: #{message}"
    logInfo:    (message) -> console.log "info: #{message}"
    logDebug:   (message) -> console.log "debug: #{message}"

consoleLogger = new ConsoleLogger()

#-------------------------------------------------------------------------------
getLogger = () ->
    return logger if logger

    if Weinre.client
        logger = Weinre.WeinreClientCommands
        return logger

    if Weinre.target
        logger = Weinre.WeinreTargetCommands
        return logger

    consoleLogger

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
