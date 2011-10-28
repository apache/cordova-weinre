
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre         = require('../common/Weinre')
WiDatabaseImpl = require('./WiDatabaseImpl')
Console        = require('./Console')

#-------------------------------------------------------------------------------
module.exports = class WeinreExtraClientCommandsImpl

    constructor: ->

    #---------------------------------------------------------------------------
    getDatabases: (callback) ->
        return unless callback
        result = WiDatabaseImpl.getDatabases()

        Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)

