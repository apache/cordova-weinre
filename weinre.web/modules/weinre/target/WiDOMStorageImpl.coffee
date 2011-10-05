
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Weinre = require('../common/Weinre')
Native = require('../common/Native')

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
            if storageArea == window.localStorage
                Native.LocalStorage_setItem key, value
            else Native.SessionStorage_setItem key, value if storageArea == window.sessionStorage
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
            if storageArea == window.localStorage
                Native.LocalStorage_removeItem key
            else
                if storageArea == window.sessionStorage
                    Native.SessionStorage_removeItem key
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

            window.localStorage.setItem = (key, value) ->
                Native.LocalStorage_setItem key, value
                _storageEventHandler storageArea: window.localStorage

            window.localStorage.removeItem = (key) ->
                Native.LocalStorage_removeItem key
                _storageEventHandler storageArea: window.localStorage

            window.localStorage.clear = ->
                Native.LocalStorage_clear()
                _storageEventHandler storageArea: window.localStorage

        if window.sessionStorage
            Weinre.wi.DOMStorageNotify.addDOMStorage
                id: 2
                host: window.location.host
                isLocalStorage: false

            window.sessionStorage.setItem = (key, value) ->
                Native.SessionStorage_setItem key, value
                _storageEventHandler storageArea: window.sessionStorage

            window.sessionStorage.removeItem = (key) ->
                Native.SessionStorage_removeItem key
                _storageEventHandler storageArea: window.sessionStorage

            window.sessionStorage.clear = ->
                Native.SessionStorage_clear()
                _storageEventHandler storageArea: window.sessionStorage

        document.addEventListener "storage", _storageEventHandler, false

#-------------------------------------------------------------------------------
_getStorageArea = (storageId) ->
      if storageId == 1
          return window.localStorage
      else return window.sessionStorage if storageId == 2

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
