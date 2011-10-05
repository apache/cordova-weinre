
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Ex       = require('./Ex')
Callback = require('./Callback')

IDLs = {}

#-------------------------------------------------------------------------------
module.exports = class IDLTools

    #---------------------------------------------------------------------------
    constructor: ->
        throw new Ex(arguments, "this class is not intended to be instantiated")

    #---------------------------------------------------------------------------
    @addIDLs: (idls) ->
        for idl in idls
            for intf in idl.interfaces
                IDLs[intf.name] = intf
                intf.module = idl.name

    #---------------------------------------------------------------------------
    @getIDL: (name) ->
        IDLs[name]

    #---------------------------------------------------------------------------
    @getIDLsMatching: (regex) ->
        results = []

        for intfName of IDLs
            intf = IDLs[intfName]
            results.push intf if intfName.match(regex)

        results

    #---------------------------------------------------------------------------
    @validateAgainstIDL: (klass, interfaceName) ->
        intf          = IDLTools.getIDL(interfaceName)
        messagePrefix = "IDL validation for #{interfaceName}: "
        if null == intf
            throw new Ex(arguments, messagePrefix + "idl not found: '#{interfaceName}'")

        errors = []
        for intfMethod in intf.methods
            classMethod = klass::[intfMethod.name]
            printName = klass.name + "::" + intfMethod.name

            if null == classMethod
                errors.push messagePrefix + "method not implemented: '#{printName}'"
                continue

            unless classMethod.length == intfMethod.parameters.length
                unless classMethod.length == intfMethod.parameters.length + 1
                    errors.push messagePrefix + "wrong number of parameters: '#{printName}'"
                    continue

        for propertyName of klass::
            continue if klass::hasOwnProperty(propertyName)
            continue if propertyName.match(/^_.*/)
            printName = klass.name + "::" + propertyName

            unless intf.methods[propertyName]
                errors.push messagePrefix + "method should not be implemented: '#{printName}'"
                continue

        return unless errors.length

        for error in errors
            require("./Weinre").logError error

    #---------------------------------------------------------------------------
    @buildProxyForIDL: (proxyObject, interfaceName) ->
        intf = IDLTools.getIDL(interfaceName)
        messagePrefix = "building proxy for IDL #{interfaceName}: "

        if null == intf
            throw new Ex(arguments, messagePrefix + "idl not found: '#{interfaceName}'")

        for intfMethod in intf.methods
            proxyObject[intfMethod.name] = getProxyMethod(intf, intfMethod)

#-------------------------------------------------------------------------------
getProxyMethod = (intf, method) ->
      result = proxyMethod = ->

          callbackId = null
          args = [].slice.call(arguments)

          if args.length > 0
              if typeof args[args.length - 1] == "function"
                  callbackId = Callback.register(args[args.length - 1])
                  args = args.slice(0, args.length - 1)

          while args.length < method.parameters.length
              args.push null

          args.push callbackId
          @__invoke intf.name, method.name, args

      result.displayName = intf.name + "__" + method.name

      result

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)

