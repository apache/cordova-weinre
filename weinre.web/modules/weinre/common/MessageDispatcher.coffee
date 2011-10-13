
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre       = require('./Weinre')
WebSocketXhr = require('./WebSocketXhr')
IDLTools     = require('./IDLTools')
Binding      = require('./Binding')
Ex           = require('./Ex')
Callback     = require('./Callback')

Verbose = false
InspectorBackend = null

#-------------------------------------------------------------------------------
module.exports = class MessageDispatcher

    #---------------------------------------------------------------------------
    constructor: (url, id) ->
        id = "anonymous" unless id
        @_url = url
        @_id = id
        @error = null
        @_opening = false
        @_opened = false
        @_closed = false
        @_interfaces = {}
        @_open()

    #---------------------------------------------------------------------------
    @setInspectorBackend: (inspectorBackend) ->
        InspectorBackend = inspectorBackend

    #---------------------------------------------------------------------------
    @verbose: (value) ->
        Verbose = not not value if arguments.length >= 1
        Verbose

    #---------------------------------------------------------------------------
    _open: ->
        return if @_opened or @_opening
        throw new Ex(arguments, "socket has already been closed") if @_closed
        @_opening = true
        @_socket = new WebSocketXhr(@_url, @_id)
        @_socket.addEventListener "open", Binding(this, "_handleOpen")
        @_socket.addEventListener "error", Binding(this, "_handleError")
        @_socket.addEventListener "message", Binding(this, "_handleMessage")
        @_socket.addEventListener "close", Binding(this, "_handleClose")

    #---------------------------------------------------------------------------
    close: ->
        return if @_closed
        @_opened = false
        @_closed = true
        @_socket.close()

    #---------------------------------------------------------------------------
    send: (data) ->
        @_socket.send data

    #---------------------------------------------------------------------------
    getWebSocket: ->
        @_socket

    #---------------------------------------------------------------------------
    registerInterface: (intfName, intf, validate) ->
        if validate
            IDLTools.validateAgainstIDL intf.constructor, intfName

        if @_interfaces[intfName]
            throw new Ex(arguments, "interface #{intfName} has already been registered")

        @_interfaces[intfName] = intf

    #---------------------------------------------------------------------------
    createProxy: (intfName) ->
        proxy = {}
        IDLTools.buildProxyForIDL proxy, intfName
        self = this

        proxy.__invoke = __invoke = (intfName, methodName, args) ->
            self._sendMethodInvocation intfName, methodName, args

        proxy

    #---------------------------------------------------------------------------
    _sendMethodInvocation: (intfName, methodName, args) ->
        unless typeof intfName == "string"
            throw new Ex(arguments, "expecting intf parameter to be a string")

        unless typeof methodName == "string"
            throw new Ex(arguments, "expecting method parameter to be a string")

        data =
            interface: intfName
            method:    methodName
            args:      args

        data = JSON.stringify(data)
        @_socket.send data

        if Verbose
            Weinre.logDebug @constructor.name + "[#{@_url}]: send #{intfName}.#{methodName}(#{JSON.stringify(args)})"

    #---------------------------------------------------------------------------
    getState: ->
        return "opening" if @_opening
        return "opened"  if @_opened
        return "closed"  if @_closed
        "unknown"

    #---------------------------------------------------------------------------
    isOpen: ->
        @_opened == true

    #---------------------------------------------------------------------------
    _handleOpen: (event) ->
        @_opening = false
        @_opened = true
        @channel = event.channel
        Callback.setConnectorChannel @channel

        if Verbose
            Weinre.logDebug @constructor.name + "[#{@_url}]: opened"

    #---------------------------------------------------------------------------
    _handleError: (message) ->
        @error = message
        @close()

        if Verbose
            Weinre.logDebug @constructor.name + "[#{@_url}]: error: " + message

    #---------------------------------------------------------------------------
    _handleMessage: (message) ->
        try
            data = JSON.parse(message.data)
        catch e
            throw new Ex(arguments, "invalid JSON data received: #{e}: '#{message.data}'")

        intfName = data["interface"]
        methodName = data.method
        args = data.args
        methodSignature = intfName + ".#{methodName}()"
        intf = @_interfaces.hasOwnProperty(intfName) and @_interfaces[intfName]

        if not intf and InspectorBackend and intfName.match(/.*Notify/)
            intf = InspectorBackend.getRegisteredDomainDispatcher(intfName.substr(0, intfName.length - 6))

        unless intf
            Weinre.notImplemented "weinre: request for non-registered interface: #{methodSignature}"
            return

        methodSignature = intf.constructor.name + ".#{methodName}()"
        method = intf[methodName]

        unless typeof method == "function"
            Weinre.notImplemented methodSignature
            return
        try
            method.apply intf, args
        catch e
            Weinre.logError "weinre: invocation exception on #{methodSignature}: " + e

        if Verbose
            Weinre.logDebug @constructor.name + "[#{@_url}]: recv #{intfName}.#{methodName}(#{JSON.stringify(args)})"

    #---------------------------------------------------------------------------
    _handleClose: ->
        @_reallyClosed = true
        if Verbose
            Weinre.logDebug @constructor.name + "[#{@_url}]: closed"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
