
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

require('./BrowserHacks')

Ex                            = require('../common/Ex')
Binding                       = require('../common/Binding')
Callback                      = require('../common/Callback')
MessageDispatcher             = require('../common/MessageDispatcher')
Weinre                        = require('../common/Weinre')
HookLib                       = require('../common/HookLib')

CheckForProblems              = require('./CheckForProblems')
NodeStore                     = require('./NodeStore')
CSSStore                      = require('./CSSStore')
ElementHighlighter            = require('./ElementHighlighter')
InjectedScriptHostImpl        = require('./InjectedScriptHostImpl')
NetworkRequest                = require('./NetworkRequest')
WeinreTargetEventsImpl        = require('./WeinreTargetEventsImpl')
WeinreExtraClientCommandsImpl = require('./WeinreExtraClientCommandsImpl')
WiConsoleImpl                 = require('./WiConsoleImpl')
WiCSSImpl                     = require('./WiCSSImpl')
WiDatabaseImpl                = require('./WiDatabaseImpl')
WiDOMImpl                     = require('./WiDOMImpl')
WiDOMStorageImpl              = require('./WiDOMStorageImpl')
WiInspectorImpl               = require('./WiInspectorImpl')
WiRuntimeImpl                 = require('./WiRuntimeImpl')

#-------------------------------------------------------------------------------
module.exports = class Target

    constructor: ->

    #---------------------------------------------------------------------------
    @main: ->
        CheckForProblems.check()
        Weinre.target = new Target()
        Weinre.target.initialize()

    #----------------------------------------------------------------------------
    setWeinreServerURLFromScriptSrc: (element) ->
        return if window.WeinreServerURL

        if element
            pattern = /(http:\/\/(.*?)\/)/
            match = pattern.exec(element.src)
            if match
                window.WeinreServerURL = match[1]
                return

        message = "unable to calculate the weinre server url; explicity set the variable window.WeinreServerURL instead"
        alert message
        throw new Ex(arguments, message)

    #---------------------------------------------------------------------------
    setWeinreServerIdFromScriptSrc: (element) ->
        return if window.WeinreServerId

        element = @getTargetScriptElement()
        hash    = "anonymous"

        if element
            attempt = element.src.split("#")[1]
            if attempt
                hash = attempt
            else
                attempt = location.hash.split("#")[1]
                hash = attempt if attempt

        window.WeinreServerId = hash

    #---------------------------------------------------------------------------
    getTargetScriptElement: ->
        elements = document.getElementsByTagName("script")
        scripts = [ "target-script.js", "target-script-min.js" ]
        i = 0

        while i < elements.length
            element = elements[i]
            j = 0
            while j < scripts.length
                return element unless -1 == element.src.indexOf("/" + scripts[j])
                j++
            i++

    #---------------------------------------------------------------------------
    initialize: () ->
        element = @getTargetScriptElement()

        @setWeinreServerURLFromScriptSrc element
        @setWeinreServerIdFromScriptSrc element

        window.WeinreServerURL += "/" unless window.WeinreServerURL[window.WeinreServerURL.length - 1] == "/"
        injectedScriptHost = new InjectedScriptHostImpl()
        Weinre.injectedScript = injectedScriptConstructor(injectedScriptHost, window, 0, "?")

        window.addEventListener "load", Binding(this, "onLoaded"), false
        document.addEventListener "DOMContentLoaded", Binding(this, "onDOMContent"), false

        @_startTime = currentTime()
        if document.readyState == "loaded"
            HookLib.ignoreHooks =>
                setTimeout (=> this.onDOMContent()), 10

        if document.readyState == "complete"
            HookLib.ignoreHooks =>
                setTimeout (=> this.onDOMContent()), 10
                setTimeout (=> this.onLoaded()), 20

#        MessageDispatcher.verbose(true)
        messageDispatcher = new MessageDispatcher(window.WeinreServerURL + "ws/target", window.WeinreServerId)
        Weinre.messageDispatcher = messageDispatcher

        Weinre.wi = {}
        Weinre.wi.Console    = new WiConsoleImpl()
        Weinre.wi.CSS        = new WiCSSImpl()
        Weinre.wi.Database   = new WiDatabaseImpl()
        Weinre.wi.DOM        = new WiDOMImpl()
        Weinre.wi.DOMStorage = new WiDOMStorageImpl()
        Weinre.wi.Inspector  = new WiInspectorImpl()
        Weinre.wi.Runtime    = new WiRuntimeImpl()

        messageDispatcher.registerInterface "Console",    Weinre.wi.Console, false
        messageDispatcher.registerInterface "CSS",        Weinre.wi.CSS, false
        messageDispatcher.registerInterface "Database",   Weinre.wi.Database, false
        messageDispatcher.registerInterface "DOM",        Weinre.wi.DOM, false
        messageDispatcher.registerInterface "DOMStorage", Weinre.wi.DOMStorage, false
        messageDispatcher.registerInterface "Inspector",  Weinre.wi.Inspector, false
        messageDispatcher.registerInterface "Runtime",    Weinre.wi.Runtime, false

        messageDispatcher.registerInterface "WeinreExtraClientCommands", new WeinreExtraClientCommandsImpl(), true
        messageDispatcher.registerInterface "WeinreTargetEvents",        new WeinreTargetEventsImpl(), true

        Weinre.wi.ApplicationCacheNotify = messageDispatcher.createProxy("ApplicationCacheNotify")
        Weinre.wi.ConsoleNotify          = messageDispatcher.createProxy("ConsoleNotify")
        Weinre.wi.DOMNotify              = messageDispatcher.createProxy("DOMNotify")
        Weinre.wi.DOMStorageNotify       = messageDispatcher.createProxy("DOMStorageNotify")
        Weinre.wi.DatabaseNotify         = messageDispatcher.createProxy("DatabaseNotify")
        Weinre.wi.InspectorNotify        = messageDispatcher.createProxy("InspectorNotify")
        Weinre.wi.TimelineNotify         = messageDispatcher.createProxy("TimelineNotify")
        Weinre.wi.NetworkNotify          = messageDispatcher.createProxy("NetworkNotify")
        Weinre.WeinreTargetCommands      = messageDispatcher.createProxy("WeinreTargetCommands")
        Weinre.WeinreExtraTargetEvents   = messageDispatcher.createProxy("WeinreExtraTargetEvents")

        messageDispatcher.getWebSocket().addEventListener "open", Binding(this, @cb_webSocketOpened)

        Weinre.nodeStore = new NodeStore()
        Weinre.cssStore  = new CSSStore()

        NetworkRequest.installNativeHooks()

    #---------------------------------------------------------------------------
    cb_webSocketOpened: () ->
        Weinre.WeinreTargetCommands.registerTarget window.location.href, Binding(this, @cb_registerTarget)

    #---------------------------------------------------------------------------
    cb_registerTarget: (targetDescription) ->
        Weinre.targetDescription = targetDescription

    #---------------------------------------------------------------------------
    onLoaded: ->
        if not Weinre.wi.InspectorNotify
            HookLib.ignoreHooks =>
                setTimeout (=> this.onLoaded()), 10
            return

        Weinre.wi.InspectorNotify.loadEventFired currentTime() - @_startTime

    #---------------------------------------------------------------------------
    onDOMContent: ->
        if not Weinre.wi.InspectorNotify
            HookLib.ignoreHooks =>
                setTimeout (=> this.onDOMContent()), 10
            return

        Weinre.wi.InspectorNotify.domContentEventFired currentTime() - @_startTime

    #---------------------------------------------------------------------------
    setDocument: () ->
        Weinre.elementHighlighter = ElementHighlighter.create() unless Weinre.elementHighlighter

        nodeId   = Weinre.nodeStore.getNodeId(document)
        nodeData = Weinre.nodeStore.getNodeData(nodeId, 2)
        Weinre.wi.DOMNotify.setDocument nodeData

    #---------------------------------------------------------------------------
    whenBodyReady: (receiver, args, func) ->
        if document.body
            func.apply(receiver, args)
            return
        
        document.addEventListener "DOMContentLoaded", 
            -> func.apply(receiver, args), 
            false

#-------------------------------------------------------------------------------
currentTime = () ->
      (new Date().getMilliseconds()) / 1000.0


#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
