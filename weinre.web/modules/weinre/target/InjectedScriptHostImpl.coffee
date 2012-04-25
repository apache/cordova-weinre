
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

Weinre = require('../common/Weinre')

#-------------------------------------------------------------------------------
module.exports = class InjectedScriptHostImpl

    constructor: ->

    #---------------------------------------------------------------------------
    clearConsoleMessages: (callback) ->
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    nodeForId: (nodeId, callback) ->
        Weinre.nodeStore.getNode nodeId

    #---------------------------------------------------------------------------
    pushNodePathToFrontend: (node, withChildren, selectInUI, callback) ->
        nodeId = Weinre.nodeStore.getNodeId(node)
        children = Weinre.nodeStore.serializeNode(node, 1)
        Weinre.wi.DOMNotify.setChildNodes nodeId, children
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback
        
        if selectInUI
            Weinre.wi.InspectorNotify.updateFocusedNode nodeId

    #---------------------------------------------------------------------------
    inspectedNode: (num, callback) ->
        nodeId = Weinre.nodeStore.getInspectedNode(num)
        nodeId

    #---------------------------------------------------------------------------
    internalConstructorName: (object) ->
        ctor = object.constructor
        ctorName = ctor.fullClassName or ctor.displayName or ctor.name
        return ctorName if ctorName and (ctorName != "Object")

        pattern = /\[object (.*)\]/
        match = pattern.exec(object.toString())

        return match[1] if match

        "Object"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
