
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Ex      = require('../common/Ex')
Binding = require('../common/Binding')
Weinre  = require('../common/Weinre')

extensions = []

#-------------------------------------------------------------------------------
module.exports = class ExtensionRegistryImpl

    constructor: ->

    #---------------------------------------------------------------------------
    getExtensionsAsync: ->
        return if extensions.length
        Weinre.WeinreClientCommands.getExtensions Binding(this, @_cb_getExtensions)

    #---------------------------------------------------------------------------
    _cb_getExtensions: (extensionsResult) ->
        extensions = extensionsResult
        @_installExtensions()

    #---------------------------------------------------------------------------
    _installExtensions: ->
        WebInspector.addExtensions extensions

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
