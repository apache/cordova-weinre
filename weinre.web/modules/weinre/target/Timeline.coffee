
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

Ex          = require('../common/Ex')
Weinre      = require('../common/Weinre')
IDGenerator = require('../common/IDGenerator')
StackTrace  = require('../common/StackTrace')
HookLib     = require('../common/HookLib')
HookSites   = require('./HookSites')

Running = false

TimerTimeouts  = {}
TimerIntervals = {}

TimelineRecordType =
    EventDispatch:            0
    Layout:                   1
    RecalculateStyles:        2
    Paint:                    3
    ParseHTML:                4
    TimerInstall:             5
    TimerRemove:              6
    TimerFire:                7
    XHRReadyStateChange:      8
    XHRLoad:                  9
    EvaluateScript:          10
    Mark:                    11
    ResourceSendRequest:     12
    ResourceReceiveResponse: 13
    ResourceFinish:          14
    FunctionCall:            15
    ReceiveResourceData:     16
    GCEvent:                 17
    MarkDOMContent:          18
    MarkLoad:                19
    ScheduleResourceRequest: 20


#-------------------------------------------------------------------------------
module.exports = class Timeline

    constructor: ->

    #---------------------------------------------------------------------------
    @start: ->
        Running = true

    #---------------------------------------------------------------------------
    @stop: ->
        Running = false

    #---------------------------------------------------------------------------
    @isRunning: ->
        Running

    #---------------------------------------------------------------------------
    @addRecord_Mark: (message) ->
        return unless Timeline.isRunning()

        record = {}
        record.type      = TimelineRecordType.Mark
        record.category  = name: "scripting"
        record.startTime = Date.now()
        record.data      = message: message

        addStackTrace record, 3

        Weinre.wi.TimelineNotify.addRecordToTimeline record

    #---------------------------------------------------------------------------
    @addRecord_EventDispatch: (event, name, category) ->
        return unless Timeline.isRunning()

        category = "scripting" unless category
        record = {}
        record.type      = TimelineRecordType.EventDispatch
        record.category  = name: category
        record.startTime = Date.now()
        record.data      = type: event.type

        Weinre.wi.TimelineNotify.addRecordToTimeline record

    #---------------------------------------------------------------------------
    @addRecord_TimerInstall: (id, timeout, singleShot) ->
        return unless Timeline.isRunning()

        record = {}
        record.type      = TimelineRecordType.TimerInstall
        record.category  = name: "scripting"
        record.startTime = Date.now()
        record.data =
            timerId:    id
            timeout:    timeout
            singleShot: singleShot

        addStackTrace record, 4

        Weinre.wi.TimelineNotify.addRecordToTimeline record

    #---------------------------------------------------------------------------
    @addRecord_TimerRemove: (id, timeout, singleShot) ->
        return unless Timeline.isRunning()

        record = {}
        record.type      = TimelineRecordType.TimerRemove
        record.category  = name: "scripting"
        record.startTime = Date.now()
        record.data =
            timerId:    id
            timeout:    timeout
            singleShot: singleShot

        addStackTrace record, 4
        Weinre.wi.TimelineNotify.addRecordToTimeline record

    #---------------------------------------------------------------------------
    @addRecord_TimerFire: (id, timeout, singleShot) ->
        return unless Timeline.isRunning()

        record = {}
        record.type      = TimelineRecordType.TimerFire
        record.category  = name: "scripting"
        record.startTime = Date.now()
        record.data =
            timerId:    id
            timeout:    timeout
            singleShot: singleShot

        Weinre.wi.TimelineNotify.addRecordToTimeline record

    #---------------------------------------------------------------------------
    @addRecord_XHRReadyStateChange: (method, url, id, xhr) ->
        return unless Timeline.isRunning()

        try 
            contentLength = xhr.getResponseHeader("Content-Length")
            contentLength = parseInt(contentLength)
            contentType   = xhr.getResponseHeader("Content-Type")
        catch e
            contentLength = 0
            contentType   = "unknown"

        record = {}
        record.startTime = Date.now()
        record.category  = name: "loading"

        if xhr.readyState == XMLHttpRequest.OPENED
            record.type = TimelineRecordType.ResourceSendRequest
            record.data =
                identifier:    id
                url:           url
                requestMethod: method

        else if xhr.readyState == XMLHttpRequest.DONE
            record.type = TimelineRecordType.ResourceReceiveResponse
            record.data =
                identifier:            id
                statusCode:            xhr.status
                mimeType:              contentType
                url:                   url

            record.data.expectedContentLength = contentLength if !isNaN(contentLength)

        else
            return

        Weinre.wi.TimelineNotify.addRecordToTimeline record

    #---------------------------------------------------------------------------
    @installGlobalListeners: ->
        if window.applicationCache
            applicationCache.addEventListener "checking",    ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.checking", "loading"    ), false
            applicationCache.addEventListener "error",       ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.error", "loading"       ), false
            applicationCache.addEventListener "noupdate",    ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.noupdate", "loading"    ), false
            applicationCache.addEventListener "downloading", ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.downloading", "loading" ), false
            applicationCache.addEventListener "progress",    ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.progress", "loading"    ), false
            applicationCache.addEventListener "updateready", ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.updateready", "loading" ), false
            applicationCache.addEventListener "cached",      ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.cached", "loading"      ), false
            applicationCache.addEventListener "obsolete",    ((e) -> Timeline.addRecord_EventDispatch e, "applicationCache.obsolete", "loading"    ), false

        window.addEventListener "error",      ((e) -> Timeline.addRecord_EventDispatch e, "window.error"      ), false
        window.addEventListener "hashchange", ((e) -> Timeline.addRecord_EventDispatch e, "window.hashchange" ), false
        window.addEventListener "message",    ((e) -> Timeline.addRecord_EventDispatch e, "window.message"    ), false
        window.addEventListener "offline",    ((e) -> Timeline.addRecord_EventDispatch e, "window.offline"    ), false
        window.addEventListener "online",     ((e) -> Timeline.addRecord_EventDispatch e, "window.online"     ), false
        window.addEventListener "scroll",     ((e) -> Timeline.addRecord_EventDispatch e, "window.scroll"     ), false

    #---------------------------------------------------------------------------
    @installNativeHooks: ->

        #-----------------------------------------------------------------------
        HookSites.window_setInterval.addHooks

            before: (receiver, args) ->
                code = args[0]
                return unless typeof(code) is "function"

                interval  = args[1]
                code      = instrumentedTimerCode(code, interval, false)
                args[0]   = code

                @userData = {}
                @userData.code     = code
                @userData.interval = interval

            after: (receiver, args, result) ->
                return if !@userData
                
                code = @userData.code
                return unless typeof(code) is "function"

                id             = result
                code.__timerId = id
                addTimer id, @userData.interval, false

        #-----------------------------------------------------------------------
        HookSites.window_clearInterval.addHooks

            before: (receiver, args) ->
                id = args[0]
                removeTimer id, false

        #-----------------------------------------------------------------------
        HookSites.window_setTimeout.addHooks

            before: (receiver, args) ->
                code = args[0]
                return unless typeof(code) is "function"

                interval  = args[1]
                code      = instrumentedTimerCode(code, interval, true)
                args[0]   = code

                @userData = {}
                @userData.code     = code
                @userData.interval = interval

            after: (receiver, args, result) ->
                return if !@userData
                
                code = @userData.code
                return unless typeof(code) is "function"

                id             = result
                code.__timerId = id
                addTimer id, @userData.interval, true

        #-----------------------------------------------------------------------
        HookSites.window_clearTimeout.addHooks

            before: (receiver, args) ->
                id = args[0]
                removeTimer id, true

        #-----------------------------------------------------------------------
        HookSites.XMLHttpRequest_open.addHooks

            before:  (receiver, args) ->
                xhr = receiver
                IDGenerator.getId xhr

                xhr.__weinre_method = args[0]
                xhr.__weinre_url    = args[1]

                xhr.addEventListener "readystatechange", getXhrEventHandler(xhr), false

#-------------------------------------------------------------------------------
getXhrEventHandler = (xhr) ->
      (event) ->
          Timeline.addRecord_XHRReadyStateChange xhr.__weinre_method, xhr.__weinre_url, IDGenerator.getId(xhr), xhr

#-------------------------------------------------------------------------------
addTimer = (id, timeout, singleShot) ->
      timerSet = (if singleShot then TimerTimeouts else TimerIntervals)

      timerSet[id] =
          id: id
          timeout: timeout
          singleShot: singleShot

      Timeline.addRecord_TimerInstall id, timeout, singleShot

#-------------------------------------------------------------------------------
removeTimer = (id, singleShot) ->
      timerSet = (if singleShot then TimerTimeouts else TimerIntervals)
      timer = timerSet[id]
      return unless timer

      Timeline.addRecord_TimerRemove id, timer.timeout, singleShot
      delete timerSet[id]

#-------------------------------------------------------------------------------
instrumentedTimerCode = (code, timeout, singleShot) ->
      return code unless typeof (code) == "function"

      instrumentedCode = ->
          result = code.apply(this, arguments)
          id = arguments.callee.__timerId
          Timeline.addRecord_TimerFire id, timeout, singleShot
          result

      instrumentedCode.displayName = code.name || code.displayName

      instrumentedCode

#-------------------------------------------------------------------------------
addStackTrace = (record, skip) ->
      skip = 1 unless skip
      trace = new StackTrace(arguments).trace
      record.stackTrace = []
      i = skip

      while i < trace.length
          record.stackTrace.push
              functionName: trace[i]
              scriptName:   ""
              lineNumber:   ""
          i++

#-------------------------------------------------------------------------------
Timeline.installGlobalListeners()
Timeline.installNativeHooks()

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
