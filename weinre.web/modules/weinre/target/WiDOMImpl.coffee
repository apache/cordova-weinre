
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
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
        Weinre.notImplemented arguments.callee.signature

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
