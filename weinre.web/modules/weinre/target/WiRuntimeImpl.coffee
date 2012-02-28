
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

Weinre = require('../common/Weinre')

#-------------------------------------------------------------------------------
module.exports = class WiRuntimeImpl

    constructor: ->

    #---------------------------------------------------------------------------
    evaluate: (expression, objectGroup, includeCommandLineAPI, callback) ->
        result = Weinre.injectedScript.evaluate(expression, objectGroup, includeCommandLineAPI)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getCompletions: (expression, includeCommandLineAPI, callback) ->
        result = Weinre.injectedScript.getCompletions(expression, includeCommandLineAPI)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getProperties: (objectId, ignoreHasOwnProperty, abbreviate, callback) ->
        objectId = JSON.stringify(objectId)
        result = Weinre.injectedScript.getProperties(objectId, ignoreHasOwnProperty, abbreviate)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    setPropertyValue: (objectId, propertyName, expression, callback) ->
        objectId = JSON.stringify(objectId)
        result = Weinre.injectedScript.setPropertyValue(objectId, propertyName, expression)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    releaseWrapperObjectGroup: (injectedScriptId, objectGroup, callback) ->
        result = Weinre.injectedScript.releaseWrapperObjectGroup(objectGroup)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
