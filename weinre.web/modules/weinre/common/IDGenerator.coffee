
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

nextIdValue = 1
idName      = "__weinre__id"

module.exports = class IDGenerator

    #---------------------------------------------------------------------------
    @checkId: (object) ->
        object[idName]

    #---------------------------------------------------------------------------
    @getId: (object, map) ->
        id = IDGenerator.checkId(object)

        unless id
            id = nextId()
            object[idName] = id

        map[id] = object if map

        id

    #---------------------------------------------------------------------------
    @next: ->
        nextId()

#-------------------------------------------------------------------------------
nextId = () ->
      result = nextIdValue
      nextIdValue += 1
      result

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
