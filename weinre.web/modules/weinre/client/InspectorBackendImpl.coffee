
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Ex                = require('../common/Ex')
IDLTools          = require('../common/IDLTools')
MessageDispatcher = require('../common/MessageDispatcher')
Weinre            = require('../common/Weinre')

#-------------------------------------------------------------------------------
module.exports = class InspectorBackendImpl

    constructor: ->
        @registeredDomainDispatchers = {}
        MessageDispatcher.setInspectorBackend this

    #---------------------------------------------------------------------------
    @setupProxies: ->
        intfNames = [
            "ApplicationCache"
            "BrowserDebugger"
            "CSS"
            "Console"
            "DOM"
            "DOMStorage"
            "Database"
            "Debugger"
            "InjectedScript"
            "Inspector"
            "Network"
            "Profiler"
            "Runtime"
        ]

        for intfName in intfNames
            proxy = Weinre.messageDispatcher.createProxy(intfName)

            if window[intfName]
                throw new Ex(arguments, "backend interface '#{intfName}' already created")

            intf = IDLTools.getIDL(intfName)
            unless intf
                throw new Ex(arguments, "interface not registered: '#{intfName}'")

            window[intfName] = {}
            for method in intf.methods
                proxyMethod = InspectorBackendImpl.getProxyMethod(proxy, method)
                InspectorBackendImpl::[method.name] = proxyMethod
                window[intfName][method.name] = proxyMethod

    #---------------------------------------------------------------------------
    @getProxyMethod: (proxy, method) ->
        ->
            proxy[method.name].apply proxy, arguments

    #---------------------------------------------------------------------------
    registerDomainDispatcher: (name, intf) ->
        @registeredDomainDispatchers[name] = intf

    #---------------------------------------------------------------------------
    getRegisteredDomainDispatcher: (name) ->
        return null unless @registeredDomainDispatchers.hasOwnProperty(name)
        @registeredDomainDispatchers[name]

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
