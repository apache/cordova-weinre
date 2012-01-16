
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

Ex         = require('./Ex')
IDLTools   = require('./IDLTools')
StackTrace = require('./StackTrace')

_notImplemented     = {}
_showNotImplemented = false
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
