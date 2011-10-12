
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
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
