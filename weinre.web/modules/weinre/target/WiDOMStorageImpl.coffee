
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
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

            HookSites.SeesionStorage_setItem.addHooks
                after: -> _storageEventHandler storageArea: window.sessionStorage

            HookSites.SeesionStorage_removeItem.addHooks
                after: -> _storageEventHandler storageArea: window.sessionStorage

            HookSites.SeesionStorage_clear.addHooks
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
