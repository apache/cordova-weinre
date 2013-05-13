
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

Ex             = require('./Ex')
Weinre         = require('./Weinre')
HookLib        = require('./HookLib')
EventListeners = require('./EventListeners')

#-------------------------------------------------------------------------------
module.exports = class WebSocketXhr

    @CONNECTING = 0
    @OPEN       = 1
    @CLOSING    = 2
    @CLOSED     = 3

    #---------------------------------------------------------------------------
    constructor: (url, id) ->
        @initialize url, id

    #---------------------------------------------------------------------------
    initialize: (url, id) ->
        id = "anonymous" unless id
        @readyState = WebSocketXhr.CONNECTING
        @_url = url
        @_id = id
        @_urlChannel = null
        @_queuedSends = []
        @_sendInProgress = true

        @_listeners =
            open:    new EventListeners()
            message: new EventListeners()
            error:   new EventListeners()
            close:   new EventListeners()

        @_getChannel()

    #---------------------------------------------------------------------------
    _getChannel: ->
        body = JSON.stringify(id: @_id)
        @_xhr @_url, "POST", body, @_handleXhrResponseGetChannel

    #---------------------------------------------------------------------------
    _handleXhrResponseGetChannel: (xhr) ->
        return @_handleXhrResponseError(xhr) unless xhr.status == 200

        try
            object = JSON.parse(xhr.responseText)
        catch e
            @_fireEventListeners "error", message: "non-JSON response from channel open request"
            @close()
            return

        unless object.channel
            @_fireEventListeners "error", message: "channel open request did not include a channel"
            @close()
            return

        @_urlChannel = @_url + "/" + object.channel
        @readyState = WebSocketXhr.OPEN

        @_fireEventListeners "open",
            message: "open"
            channel: object.channel

        @_sendInProgress = false
        @_sendQueued()
        @_readLoop()

    #---------------------------------------------------------------------------
    _readLoop: ->
        return if @readyState == WebSocketXhr.CLOSED
        return if @readyState == WebSocketXhr.CLOSING

        @_xhr @_urlChannel, "GET", "", @_handleXhrResponseGet

    #---------------------------------------------------------------------------
    _handleXhrResponseGet: (xhr) ->
        self = this
        return @_handleXhrResponseError(xhr) unless xhr.status == 200

        try
            datum = JSON.parse(xhr.responseText)
        catch e
            @readyState = WebSocketXhr.CLOSED
            @_fireEventListeners "error", message: "non-JSON response from read request"
            return

        HookLib.ignoreHooks ->
            setTimeout (->
                self._readLoop()
            ), 0

        for data in datum
            self._fireEventListeners "message", data: data

    #---------------------------------------------------------------------------
    send: (data) ->
        unless typeof data == "string"
            throw new Ex(arguments, @constructor.name + ".send")

        @_queuedSends.push data
        return if @_sendInProgress
        @_sendQueued()

    #---------------------------------------------------------------------------
    _sendQueued: ->
        return if @_queuedSends.length == 0
        return if @readyState == WebSocketXhr.CLOSED
        return if @readyState == WebSocketXhr.CLOSING

        datum = JSON.stringify(@_queuedSends)
        @_queuedSends = []
        @_sendInProgress = true
        @_xhr @_urlChannel, "POST", datum, @_handleXhrResponseSend

    #---------------------------------------------------------------------------
    _handleXhrResponseSend: (xhr) ->
        httpSocket = this
        return @_handleXhrResponseError(xhr) unless xhr.status == 200

        @_sendInProgress = false

        HookLib.ignoreHooks ->
            setTimeout (->
                httpSocket._sendQueued()
            ), 0

    #---------------------------------------------------------------------------
    close: ->
        @_sendInProgress = true
        @readyState = WebSocketXhr.CLOSING

        @_fireEventListeners "close",
            message: "closing"
            wasClean: true

        @readyState = WebSocketXhr.CLOSED

    #---------------------------------------------------------------------------
    addEventListener: (type, listener, useCapture) ->
        @_getListeners(type).add listener, useCapture

    #---------------------------------------------------------------------------
    removeEventListener: (type, listener, useCapture) ->
        @_getListeners(type).remove listener, useCapture

    #---------------------------------------------------------------------------
    _fireEventListeners: (type, event) ->
        return if @readyState == WebSocketXhr.CLOSED

        event.target = this
        @_getListeners(type).fire event

    #---------------------------------------------------------------------------
    _getListeners: (type) ->
        listeners = @_listeners[type]
        if null == listeners
            throw new Ex(arguments, "invalid event listener type: '#{type}'")
        listeners

    #---------------------------------------------------------------------------
    _handleXhrResponseError: (xhr) ->
        if xhr.status == 404
            @close()
            return

        @_fireEventListeners "error",
            target: this
            status: xhr.status
            message: "error from XHR invocation: " + xhr.statusText

        Weinre.logError "error from XHR invocation: #{xhr.status}: " + xhr.statusText

    #---------------------------------------------------------------------------
    _xhr: (url, method, data, handler) ->
        if null == handler
            throw new Ex(arguments, "handler must not be null")

        # Fix for XMLHttpRequest issue in Cordova for WP8 - Cordova overrides standard XMLHttpRequest object but
        # overriden object causes dropping connections between target and server, so we should use Original
        # XMLHttpRequest that is stored in XMLHttpRequest.noConflict.
        xhr = (if XMLHttpRequest.noConflict then new XMLHttpRequest.noConflict() else new XMLHttpRequest())
        xhr.httpSocket = this
        xhr.httpSocketHandler = handler
        xhr.onreadystatechange = _xhrEventHandler

        HookLib.ignoreHooks ->
            xhr.open method, url, true

        xhr.setRequestHeader "Content-Type", "text/plain"

        HookLib.ignoreHooks ->
            xhr.send data

#-------------------------------------------------------------------------------
_xhrEventHandler = (event) ->
      xhr = event.target
      return unless xhr.readyState == 4

      xhr.httpSocketHandler.call xhr.httpSocket, xhr

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
