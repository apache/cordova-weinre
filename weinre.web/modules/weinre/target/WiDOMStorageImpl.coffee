
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

Weinre    = require('../common/Weinre')
HookSites = require('./HookSites')

#-------------------------------------------------------------------------------
module.exports = class WiDOMStorageImpl

    constructor: ->

    #---------------------------------------------------------------------------
    getDOMStorageEntries: (storageId, callback) ->
        storageArea = _getStorageArea(storageId)

        unless storageArea
            Weinre.logWarning arguments.callee.signature + " passed an invalid storageId: " + storageId
            return

        result = []
        length = storageArea.length
        i = 0

        while i < length
            key = storageArea.key(i)
            val = storageArea.getItem(key)
            result.push [ key, val ]
            i++

        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    setDOMStorageItem: (storageId, key, value, callback) ->
        storageArea = _getStorageArea(storageId)

        unless storageArea
            Weinre.logWarning arguments.callee.signature + " passed an invalid storageId: " + storageId
            return

        result = true
        try
            HookLib.ignoreHooks ->
                if storageArea == window.localStorage
                    localStorage.setItem key, value
                else if storageArea == window.sessionStorage
                    sessionStorage.setItem key, value
        catch e
            result = false

        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ]

    #---------------------------------------------------------------------------
    removeDOMStorageItem: (storageId, key, callback) ->
        storageArea = _getStorageArea(storageId)

        unless storageArea
            Weinre.logWarning arguments.callee.signature + " passed an invalid storageId: " + storageId
            return

        result = true
        try
            HookLib.ignoreHooks ->
                if storageArea == window.localStorage
                    localStorage.removeItem key
                else if storageArea == window.sessionStorage
                    sessionStorage.removeItem key
        catch e
            result = false

        Weinre.WeinreTargetCommands.sendClientCallback callback, [ result ] if callback

    #---------------------------------------------------------------------------
    initialize: ->
        if window.localStorage
            Weinre.wi.DOMStorageNotify.addDOMStorage
                id: 1
                host: window.location.host
                isLocalStorage: true

            HookSites.LocalStorage_setItem.addHooks
                after: -> _storageEventHandler storageArea: window.localStorage

            HookSites.LocalStorage_removeItem.addHooks
                after: -> _storageEventHandler storageArea: window.localStorage

            HookSites.LocalStorage_clear.addHooks
                after: -> _storageEventHandler storageArea: window.localStorage

        if window.sessionStorage
            Weinre.wi.DOMStorageNotify.addDOMStorage
                id: 2
                host: window.location.host
                isLocalStorage: false

            HookSites.SessionStorage_setItem.addHooks
                after: -> _storageEventHandler storageArea: window.sessionStorage

            HookSites.SessionStorage_removeItem.addHooks
                after: -> _storageEventHandler storageArea: window.sessionStorage

            HookSites.SessionStorage_clear.addHooks
                after: -> _storageEventHandler storageArea: window.sessionStorage

        document.addEventListener "storage", _storageEventHandler, false

#-------------------------------------------------------------------------------
_getStorageArea = (storageId) ->
      if storageId == 1
          return window.localStorage
      else if storageId == 2
          return window.sessionStorage

      null

#-------------------------------------------------------------------------------
_storageEventHandler = (event) ->
      if event.storageArea == window.localStorage
          storageId = 1
      else if event.storageArea == window.sessionStorage
          storageId = 2
      else
          return

      Weinre.wi.DOMStorageNotify.updateDOMStorage storageId

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
