
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

module.exports = class CheckForProblems

    constructor: ->

    #---------------------------------------------------------------------------
    @check: ->
        checkForOldPrototypeVersion()

#-------------------------------------------------------------------------------
checkForOldPrototypeVersion = () ->
      badVersion = false
      return if typeof Prototype == "undefined"
      return unless Prototype.Version

      badVersion = true if Prototype.Version.match(/^1\.5.*/)
      badVersion = true if Prototype.Version.match(/^1\.6.*/)

      if badVersion
          alert "Sorry, weinre is not support in versions of Prototype earlier than 1.7"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
