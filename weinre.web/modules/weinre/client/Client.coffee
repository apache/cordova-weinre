
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

IDLTools          = require('../common/IDLTools')
Callback          = require('../common/Callback')
Weinre            = require('../common/Weinre')
MessageDispatcher = require('../common/MessageDispatcher')
Binding           = require('../common/Binding')
IDGenerator       = require('../common/IDGenerator')

InspectorBackendImpl        = require('./InspectorBackendImpl')
InspectorFrontendHostImpl   = require('./InspectorFrontendHostImpl')
WeinreClientEventsImpl      = require('./WeinreClientEventsImpl')
WeinreExtraTargetEventsImpl = require('./WeinreExtraTargetEventsImpl')
RemotePanel                 = require('./RemotePanel')

AutoConnect = true

Weinre.showNotImplemented()

#-------------------------------------------------------------------------------
module.exports = class Client

    constructor: ->

    #---------------------------------------------------------------------------
    initialize: ->
    
        addHack_DOMNotify_setChildNodes()
        
        window.addEventListener 'load', Binding(this, 'onLoaded'), false

        messageDispatcher = new MessageDispatcher('../ws/client', @_getId())
        Weinre.messageDispatcher = messageDispatcher

        InspectorBackendImpl.setupProxies()

        Weinre.WeinreClientCommands      = messageDispatcher.createProxy('WeinreClientCommands')
        Weinre.WeinreExtraClientCommands = messageDispatcher.createProxy('WeinreExtraClientCommands')

        messageDispatcher.registerInterface 'WeinreExtraTargetEvents', new WeinreExtraTargetEventsImpl(), false
        messageDispatcher.registerInterface 'WebInspector',            WebInspector,                      false
        messageDispatcher.registerInterface 'WeinreClientEvents',      new WeinreClientEventsImpl(this),  false
        messageDispatcher.registerInterface 'InspectorFrontendHost',   InspectorFrontendHost,             false

        WebInspector.mainResource = {}
        WebInspector.mainResource.url = location.href

    #---------------------------------------------------------------------------
    _getId: ->
        hash = location.href.split('#')[1]
        return hash if hash
        'anonymous'

    #---------------------------------------------------------------------------
    uiAvailable: ->
        WebInspector.panels and WebInspector.panels.remote

    #---------------------------------------------------------------------------
    autoConnect: (value) ->
        AutoConnect = not not value if arguments.length >= 1
        AutoConnect

    #---------------------------------------------------------------------------
    _installRemotePanel: ->
        WebInspector.panels.remote = new RemotePanel()

        panel   = WebInspector.panels.remote
        toolbar = document.getElementById('toolbar')

        WebInspector.addPanelToolbarIcon toolbar, panel, toolbar.childNodes[1]
        WebInspector.panelOrder.unshift WebInspector.panelOrder.pop()
        WebInspector.currentPanel = panel

        toolButtonsToHide = [ 'scripts' ]
        toolButtonsToHide.push 'resources', 'network', 'timeline', 'profiles', 'audits' if navigator.userAgent.match(/MSIE/i)
        for toolButtonToHide in toolButtonsToHide
            continue unless WebInspector.panels[toolButtonToHide]
            continue unless WebInspector.panels[toolButtonToHide].toolbarItem

            WebInspector.panels[toolButtonToHide].toolbarItem.style.display = 'none'

        button = document.getElementById('dock-status-bar-item')
        button.style.display = 'none' if button

    #---------------------------------------------------------------------------
    onLoaded: ->
        Weinre.WeinreClientCommands.registerClient Binding(this, @cb_registerClient)

        @_installRemotePanel()

    #---------------------------------------------------------------------------
    cb_registerClient: (clientDescription) ->
        Weinre.clientDescription = clientDescription

        if @uiAvailable()
            WebInspector.panels.remote.setCurrentClient clientDescription.channel
            WebInspector.panels.remote.afterInitialConnection()

        Weinre.messageDispatcher.getWebSocket().addEventListener 'close', Binding(this, @cb_webSocketClosed)

    #---------------------------------------------------------------------------
    cb_webSocketClosed: ->

        setTimeout (->
            WebInspector.panels.remote.connectionClosed()
            WebInspector.currentPanel = WebInspector.panels.remote
        ), 1000

    #---------------------------------------------------------------------------
    @main: ->
        Weinre.client = new Client()
        Weinre.client.initialize()

        window.installWebInspectorAPIsource = installWebInspectorAPIsource
    

#-------------------------------------------------------------------------------
old_DOMNotify_setChildNodes = null

#-------------------------------------------------------------------------------
new_DOMNotify_setChildNodes = (parentId, payloads) ->
    domNode  = this._domAgent._idToDOMNode[parentId]

    if domNode.children 
        if domNode.children.length > 0
            return
    
    old_DOMNotify_setChildNodes.call(this, parentId, payloads)

#-------------------------------------------------------------------------------
addHack_DOMNotify_setChildNodes = ->
    old_DOMNotify_setChildNodes = WebInspector.DOMDispatcher::setChildNodes
    
    WebInspector.DOMDispatcher::setChildNodes = new_DOMNotify_setChildNodes
    
#-------------------------------------------------------------------------------
installWebInspectorAPIsource = () ->
      return if 'webInspector' of window

      extensionAPI = window.parent.InspectorFrontendHost.getExtensionAPI()
      extensionAPI = extensionAPI.replace('location.hostname + location.port', "location.hostname + ':' + location.port")

      id = IDGenerator.next()

      console.log "installing webInspector with injectedScriptId: #{id}"

      extensionAPI += "(null, null, #{id})"
      extensionAPI

#-------------------------------------------------------------------------------
require('../common/MethodNamer').setNamesForClass(module.exports)
