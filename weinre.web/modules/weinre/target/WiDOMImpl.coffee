
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
module.exports = class WiDOMImpl

    constructor: ->

    #---------------------------------------------------------------------------
    getChildNodes: (nodeId, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        children = Weinre.nodeStore.serializeNodeChildren(node, 1)
        Weinre.wi.DOMNotify.setChildNodes nodeId, children
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    setAttribute: (elementId, name, value, callback) ->
        element = Weinre.nodeStore.getNode(elementId)

        unless element
            Weinre.logWarning arguments.callee.signature + " passed an invalid elementId: " + elementId
            return

        element.setAttribute name, value
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    removeAttribute: (elementId, name, callback) ->
        element = Weinre.nodeStore.getNode(elementId)

        unless element
            Weinre.logWarning arguments.callee.signature + " passed an invalid elementId: " + elementId
            return

        element.removeAttribute name
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    setTextNodeValue: (nodeId, value, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        node.nodeValue = value
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    getEventListenersForNode: (nodeId, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    copyNode: (nodeId, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    removeNode: (nodeId, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        unless node.parentNode
            Weinre.logWarning arguments.callee.signature + " passed a parentless node: " + node
            return

        node.parentNode.removeChild node
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    changeTagName: (nodeId, newTagName, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    getOuterHTML: (nodeId, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        value = node.outerHTML
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ value ]

    #---------------------------------------------------------------------------
    setOuterHTML: (nodeId, outerHTML, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        node.outerHTML = outerHTML
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    addInspectedNode: (nodeId, callback) ->
        Weinre.nodeStore.addInspectedNode nodeId
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    performSearch: (query, runSynchronously, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    searchCanceled: (callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    pushNodeByPathToFrontend: (path, callback) ->
        parts = path.split(",")
        
        curr   = document
        currId = null
        
        nodeId = Weinre.nodeStore.getNodeId(curr)
        @getChildNodes(nodeId)
        
        for i in [0...parts.length] by 2
            index    = parseInt(parts[i])
            nodeName = parts[i+1]
            
            return if isNaN(index) 
            
            childNodeIds = Weinre.nodeStore.childNodeIds(curr)
            currId = childNodeIds[index]
            return if !currId
            
            @getChildNodes(currId)
            curr = Weinre.nodeStore.getNode(currId)
            
            return if curr.nodeName != nodeName

        if callback && currId
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ currId ]

    #---------------------------------------------------------------------------
    resolveNode: (nodeId, callback) ->
        result = Weinre.injectedScript.resolveNode(nodeId)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getNodeProperties: (nodeId, propertiesArray, callback) ->
        propertiesArray = JSON.stringify(propertiesArray)
        result = Weinre.injectedScript.getNodeProperties(nodeId, propertiesArray)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getNodePrototypes: (nodeId, callback) ->
        result = Weinre.injectedScript.getNodePrototypes(nodeId)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    pushNodeToFrontend: (objectId, callback) ->
        objectId = JSON.stringify(objectId)
        result = Weinre.injectedScript.pushNodeToFrontend(objectId)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
