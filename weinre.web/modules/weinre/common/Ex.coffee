
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

StackTrace = require('./StackTrace')

#-------------------------------------------------------------------------------
module.exports = class Ex

    #---------------------------------------------------------------------------
    @catching: (func) ->
        try
            func.call(this)
        catch e
            console.log "runtime error: #{e}"
            StackTrace.dump arguments

    #---------------------------------------------------------------------------
    constructor: (args, message) ->
        if not args or not args.callee
            throw Ex(arguments, "first parameter must be an Arguments object")

        StackTrace.dump args
        message = "threw error: " + message if message instanceof Error
        message = prefix(args, message)
        message

#-------------------------------------------------------------------------------
prefix = (args, string) ->
      return args.callee.signature   + ": " + string if args.callee.signature
      return args.callee.displayName + ": " + string if args.callee.displayName
      return args.callee.name        + ": " + string if args.callee.name

      "<anonymous>" + ": " + string

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
