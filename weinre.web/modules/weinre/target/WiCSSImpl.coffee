
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
