
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre = require('../common/Weinre')

#-------------------------------------------------------------------------------
module.exports = class WiRuntimeImpl

    constructor: ->

    #---------------------------------------------------------------------------
    evaluate: (expression, objectGroup, includeCommandLineAPI, callback) ->
        result = Weinre.injectedScript.evaluate(expression, objectGroup, includeCommandLineAPI)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getCompletions: (expression, includeCommandLineAPI, callback) ->
        result = Weinre.injectedScript.getCompletions(expression, includeCommandLineAPI)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    getProperties: (objectId, ignoreHasOwnProperty, abbreviate, callback) ->
        objectId = JSON.stringify(objectId)
        result = Weinre.injectedScript.getProperties(objectId, ignoreHasOwnProperty, abbreviate)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    setPropertyValue: (objectId, propertyName, expression, callback) ->
        objectId = JSON.stringify(objectId)
        result = Weinre.injectedScript.setPropertyValue(objectId, propertyName, expression)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    releaseWrapperObjectGroup: (injectedScriptId, objectGroup, callback) ->
        result = Weinre.injectedScript.releaseWrapperObjectGroup(objectGroupName)
        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
