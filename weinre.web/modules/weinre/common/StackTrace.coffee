
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

module.exports = class StackTrace

    constructor: (args) ->
        if not args or not args.callee
            throw Error("first parameter to #{arguments.callee.signature} must be an Arguments object")

        @trace = getTrace(args)

    #---------------------------------------------------------------------------
    @dump: (args) ->
        args = args or arguments
        stackTrace = new StackTrace(args)
        stackTrace.dump()

    #---------------------------------------------------------------------------
    dump: ->
        console.log "StackTrace:"
        for frame in @trace
            console.log "    " + frame

#-------------------------------------------------------------------------------
getTrace = (args) ->
      result = []
      visitedFuncs = []
      func = args.callee

      while func
          if func.signature
              result.push func.signature
          else if func.displayName
              result.push func.displayName
          else if func.name
              result.push func.name
          else
              result.push "<anonymous>"

          unless -1 == visitedFuncs.indexOf(func)
              result.push "... recursion"
              return result

          visitedFuncs.push func
          func = func.caller

      result

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
