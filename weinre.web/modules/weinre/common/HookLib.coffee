
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

        if typeof @target == 'undefined'
            return
        else
            hookedFunction   = getHookedFunction(@target, this)
            #In IE we should not override standard storage functions because IE does it incorrectly - all values that set as
            # storage properties (e.g. localStorage.setItem = function()[...]) are cast to String.
            # That leads to "Function expected" exception when any of overridden function is called.
            object[property] = hookedFunction  unless navigator.userAgent.match(/MSIE/i) and (object is localStorage or object is sessionStorage)

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
