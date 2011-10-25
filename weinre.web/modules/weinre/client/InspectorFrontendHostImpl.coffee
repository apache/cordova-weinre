
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre   = require('../common/Weinre')
IDLTools = require('../common/IDLTools')

_extensionAPI = null

#-------------------------------------------------------------------------------
module.exports = class InspectorFrontendHostImpl

    constructor: ->
        @_getPlatformAndPort()

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
