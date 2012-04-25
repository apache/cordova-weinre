
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
IDLTools = require('../common/IDLTools')

_extensionAPI = null

#-------------------------------------------------------------------------------
module.exports = class InspectorFrontendHostImpl

    constructor: ->
        @_getPlatformAndPort()

    #---------------------------------------------------------------------------
    showContextMenu: ->

    #---------------------------------------------------------------------------
    loaded: ->

    #---------------------------------------------------------------------------
    localizedStringsURL: ->
        "nls/English.lproj/localizedStrings.js"

    #---------------------------------------------------------------------------
    hiddenPanels: ->
        # "audits,profiles,network"
        "audits,profiles"

    #---------------------------------------------------------------------------
    platform: ->
        "weinre"

    #---------------------------------------------------------------------------
    port: ->
        "weinre"

    #---------------------------------------------------------------------------
    sendMessageToBackend: (message) ->
        object = JSON.parse(message)
        object[1] = "<long script elided>" if object[0] == "setInjectedScriptSource"
        Weinre.logInfo arguments.callee.name + "(#{JSON.stringify(object, null, 4)})"

    #---------------------------------------------------------------------------
    setExtensionAPI: (extensionAPI) ->
        _extensionAPI = extensionAPI

    #---------------------------------------------------------------------------
    getExtensionAPI: ->
        _extensionAPI

    #---------------------------------------------------------------------------
    inspectedURLChanged: ->

    #---------------------------------------------------------------------------
    _getPlatformAndPort: ->
        @_platform = "weinre"
        @_platformFlavor = "weinre"
        @_port = "weinre"
        return if true
        uas = navigator.userAgent
        if uas.match(/mac os x/i)
            @_platform = "mac"
        else if uas.match(/macintosh/i)
            @_platform = "mac"
        else if uas.match(/linux/i)
            @_platform = "linux"
        else @_platform = "windows" if uas.match(/windows/i)
        url = window.location.href
        splits = url.split("#", 2)
        if splits.length > 1
            properties = splits[1]
            properties = properties.split("&")
            for property in properties
                pieces = property.split("=")
                if pieces.length > 1
                    key = pieces[0]
                    val = pieces[1]
                    if key == "platform"
                        @_platform = val
                    else if key == "platformFlavor"
                        @_platformFlavor = val
                    else @_port = val if key == "port"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
