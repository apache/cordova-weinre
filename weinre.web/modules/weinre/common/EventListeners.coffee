
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

Ex     = require('./Ex')
Weinre = require('./Weinre')

#-------------------------------------------------------------------------------
module.exports = class EventListeners

    constructor: ->
        @listeners = []

    #---------------------------------------------------------------------------
    add: (listener, useCapture) ->
        @listeners.push [ listener, useCapture ]

    #---------------------------------------------------------------------------
    remove: (listener, useCapture) ->
        listeners = @listeners.slice()

        for _listener in listeners
            continue unless _listener[0] == listener
            continue unless _listener[1] == useCapture

            @_listeners.splice i, 1
            return

    #---------------------------------------------------------------------------
    fire: (event) ->
        listeners = @listeners.slice()
        for listener in listeners
            listener = listener[0]

            if typeof listener is "function"
                try
                    listener.call null, event
                catch e
                    Weinre.logError "#{arguments.callee.name} invocation exception: #{e}"
                continue

            if typeof listener?.handleEvent isnt "function"
                throw new Ex(arguments, "listener does not implement the handleEvent() method")

            try
                listener.handleEvent.call listener, event
            catch e
                Weinre.logError "#{arguments.callee.name} invocation exception: #{e}"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)

