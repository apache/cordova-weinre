
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

Ex = require('./Ex')

CallbackTable    = {}
CallbackIndex    = 1
ConnectorChannel = "???"

#-------------------------------------------------------------------------------
module.exports = class Callback

    constructor: ->
        throw new Ex(arguments, "this class is not intended to be instantiated")

    #---------------------------------------------------------------------------
    @setConnectorChannel: (connectorChannel) ->
        ConnectorChannel = "" + connectorChannel

    #---------------------------------------------------------------------------
    @register: (callback) ->
        callback = [ null, callback ] if typeof callback == "function"
        unless typeof callback.slice == "function"
            throw new Ex(arguments, "callback must be an array or function")

        receiver = callback[0]
        func = callback[1]
        data = callback.slice(2)
        func = receiver[func] if typeof func == "string"

        unless typeof func == "function"
            throw new Ex(arguments, "callback function was null or not found")

        index = ConnectorChannel + "::" + CallbackIndex

        CallbackIndex++
        CallbackIndex = 1 if CallbackIndex >= 65536 * 65536
        CallbackTable[index] = [ receiver, func, data ]

        index

    #---------------------------------------------------------------------------
    @deregister: (index) ->
        delete CallbackTable[index]

    #---------------------------------------------------------------------------
    @invoke: (index, args) ->
        callback = CallbackTable[index]

        unless callback
            throw new Ex(arguments, "callback #{index} not registered or already invoked")

        receiver = callback[0]
        func = callback[1]
        args = callback[2].concat(args)

        try
            func.apply receiver, args
        catch e
            funcName = func.name || func.signature
            funcName = "<unnamed>" unless funcName
            require("./Weinre").logError arguments.callee.signature + " exception invoking callback: #{funcName}(#{args.join(',')}): " + e
        finally
            Callback.deregister index

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
