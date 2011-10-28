
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre = require('../common/Weinre')

#-------------------------------------------------------------------------------
module.exports = class WiCSSImpl

    constructor: ->
        @dummyComputedStyle = false

    #---------------------------------------------------------------------------
    getStylesForNode: (nodeId, callback) ->
        result = {}
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        if @dummyComputedStyle
            computedStyle =
                styleId: null
                properties: []
                shorthandValues: []
                cssProperties: []
        else
            computedStyle = Weinre.cssStore.getComputedStyle(node)

        result =
            inlineStyle:     Weinre.cssStore.getInlineStyle(node)
            computedStyle:   computedStyle
            matchedCSSRules: Weinre.cssStore.getMatchedCSSRules(node)
            styleAttributes: Weinre.cssStore.getStyleAttributes(node)
            pseudoElements:  Weinre.cssStore.getPseudoElements(node)
            inherited:       []

        parentNode = node.parentNode
        while parentNode
            parentStyle =
                inlineStyle:     Weinre.cssStore.getInlineStyle(parentNode)
                matchedCSSRules: Weinre.cssStore.getMatchedCSSRules(parentNode)

            result.inherited.push parentStyle
            parentNode = parentNode.parentNode

        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getComputedStyleForNode: (nodeId, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        result = Weinre.cssStore.getComputedStyle(node)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getInlineStyleForNode: (nodeId, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        result = Weinre.cssStore.getInlineStyle(node)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getAllStyles: (callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    getStyleSheet: (styleSheetId, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    getStyleSheetText: (styleSheetId, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    setStyleSheetText: (styleSheetId, text, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    setPropertyText: (styleId, propertyIndex, text, overwrite, callback) ->
        result = Weinre.cssStore.setPropertyText(styleId, propertyIndex, text, overwrite)
        Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ] if callback

    #---------------------------------------------------------------------------
    toggleProperty: (styleId, propertyIndex, disable, callback) ->
        result = Weinre.cssStore.toggleProperty(styleId, propertyIndex, disable)
        Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ] if callback

    #---------------------------------------------------------------------------
    setRuleSelector: (ruleId, selector, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    addRule: (contextNodeId, selector, callback) ->
        Weinre.notImplemented arguments.callee.signature

    #---------------------------------------------------------------------------
    querySelectorAll: (documentId, selector, callback) ->
        Weinre.notImplemented arguments.callee.signature

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
