
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

            intf = IDLTools.getIDL(intfName)
            unless intf
                throw new Ex(arguments, "interface not registered: '#{intfName}'")

            for method in intf.methods
                proxyMethod = InspectorBackendImpl.getProxyMethod(proxy, method)
                InspectorBackendImpl::[method.name] = proxyMethod

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
