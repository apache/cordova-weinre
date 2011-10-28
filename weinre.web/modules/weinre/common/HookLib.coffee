
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

HookLib = exports

#-------------------------------------------------------------------------------
HookSites   = []
IgnoreHooks = 0

module.exports = class HookLib

    #---------------------------------------------------------------------------
    @addHookSite = (object, property) ->
        getHookSite object, property, true

    #---------------------------------------------------------------------------
    @getHookSite = (object, property) ->
        getHookSite object, property, false

    #---------------------------------------------------------------------------
    @ignoreHooks = (func) ->
        try
            IgnoreHooks++
            result = func.call()
        finally
            IgnoreHooks--
        result

#-------------------------------------------------------------------------------
getHookSite = (object, property, addIfNotFound) ->
    i = 0

    for hookSite in HookSites
        continue  unless hookSite.object == object
        continue  unless hookSite.property == property
        return hookSite

    return null unless addIfNotFound

    hookSite = new HookSite(object, property)
    HookSites.push hookSite
    hookSite

#-------------------------------------------------------------------------------
class HookSite

    #---------------------------------------------------------------------------
    constructor: (object, property) ->
        @object = object
        @property = property
        @target = object[property]
        @hookss = []

        hookedFunction   = getHookedFunction(@target, this)
        object[property] = hookedFunction

    #---------------------------------------------------------------------------
    addHooks: (hooks) ->
        @hookss.push hooks

    #---------------------------------------------------------------------------
    removeHooks: (hooks) ->
        for i in [0..@hookss.length]
            if @hookss[i] == hooks
                @hookss.splice i, 1
                return

#-------------------------------------------------------------------------------
getHookedFunction = (func, hookSite) ->
    hookedFunction = ->

        callBeforeHooks hookSite, this, arguments
        try
            result = func.apply(this, arguments)
        catch e
            callExceptHooks hookSite, this, arguments, e
            throw e
        finally
            callAfterHooks hookSite, this, arguments, result

        result

    hookedFunction.displayName = func.displayName || func.name

    hookedFunction

#-------------------------------------------------------------------------------
callBeforeHooks = (hookSite, receiver, args) ->
    return if IgnoreHooks > 0

    for hooks in hookSite.hookss
        hooks.before.call hooks, receiver, args if hooks.before

#-------------------------------------------------------------------------------
callAfterHooks = (hookSite, receiver, args, result) ->
    return if IgnoreHooks > 0

    for hooks in hookSite.hookss
        hooks.after.call hooks, receiver, args, result if hooks.after

#-------------------------------------------------------------------------------
callExceptHooks = (hookSite, receiver, args, e) ->
    return if IgnoreHooks > 0

    for hooks in hookSite.hookss
        hooks.except.call hooks, receiver, args, e if hooks.except

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
