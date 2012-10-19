
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

StackTrace  = require('../common/StackTrace')
IDGenerator = require('../common/IDGenerator')
HookLib     = require('../common/HookLib')
Weinre      = require('../common/Weinre')
Ex          = require('../common/Ex')
HookSites   = require('./HookSites')

Loader =
    url:      window.location.href
    frameId:  0
    loaderId: 0

#-------------------------------------------------------------------------------
module.exports = class NetworkRequest

    #---------------------------------------------------------------------------
    constructor: (@xhr, @id, @method, @url, @stackTrace) ->

    #---------------------------------------------------------------------------
    handleSend: (data) ->
        Weinre.wi.NetworkNotify.identifierForInitialRequest(@id, @url, Loader, @stackTrace)

        time             = Date.now() / 1000.0
        request          = getRequest(@url, @method, @xhr, data)
        redirectResponse = {isNull: true}

        Weinre.wi.NetworkNotify.willSendRequest(@id, time, request, redirectResponse)

    #---------------------------------------------------------------------------
    handleHeadersReceived: ->
        time     = Date.now() / 1000.0
        response = getResponse(@xhr)
        Weinre.wi.NetworkNotify.didReceiveResponse(@id, time, "XHR", response)

    #---------------------------------------------------------------------------
    handleLoading: ->

    #---------------------------------------------------------------------------
    handleDone: ->
        sourceString = ""
        try
            sourceString = @xhr.responseText
        catch e
            # leave sourceString as ""

        Weinre.wi.NetworkNotify.setInitialContent(@id, sourceString, "XHR")

        time       = Date.now() / 1000.0
        status     = @xhr.status
        status     = 200 if status == 0
        statusText = @xhr.statusText

        success = status >= 200 and status < 300

        if success
            Weinre.wi.NetworkNotify.didFinishLoading(@id, time)
        else
            description = "#{status} - #{statusText}"
            Weinre.wi.NetworkNotify.didFailLoading(@id, time, description)

    #---------------------------------------------------------------------------
    @installNativeHooks: ->

        #-----------------------------------------------------------------------
        HookSites.XMLHttpRequest_open.addHooks

            before:  (receiver, args) ->
                xhr = receiver

                method = args[0]
                url    = args[1]
                id     = IDGenerator.next()

                rawStackTrace = new StackTrace(args).trace.slice(1)

                stackTrace = []
                for frame in rawStackTrace
                    stackTrace.push({functionName: frame})

                xhr.__weinreNetworkRequest__ = new NetworkRequest(xhr, id, method, url, stackTrace)

                HookLib.ignoreHooks ->
                    xhr.addEventListener "readystatechange", getXhrEventHandler(xhr), false

        #-----------------------------------------------------------------------
        HookSites.XMLHttpRequest_send.addHooks

            before:  (receiver, args) ->
                xhr  = receiver
                data = args[0]
                nr   = xhr.__weinreNetworkRequest__
                return unless nr

                nr.handleSend(data)

#-------------------------------------------------------------------------------
getRequest = (url, method, xhr, data) ->

    return {
        url:              url
        httpMethod:       method
        httpHeaderFields: {}
        requestFormData:  getFormData(url, data)
    }

#-------------------------------------------------------------------------------
getResponse = (xhr) ->
    contentType = xhr.getResponseHeader("Content-Type")
    contentType ||= 'application/octet-stream'

    [contentType, encoding] = splitContentType(contentType)

    headers = getHeaders(xhr)

    result =
        mimeType:              contentType
        textEncodingName:      encoding
        httpStatusCode:        xhr.status
        httpStatusText:        xhr.statusText
        httpHeaderFields:      headers
        connectionReused:      false
        connectionID:          0
        wasCached:             false

    contentLength = xhr.getResponseHeader("Content-Length")
    contentLength = parseInt(contentLength)
    result.expectedContentLength = contentLength if !isNaN(contentLength)

    return result

#-------------------------------------------------------------------------------
getHeaders = (xhr) ->
    string = xhr.getAllResponseHeaders()
    lines = string.split('\r\n')

    result = {}
    for line in lines
        line = trim(line)
        break if line == ""

        [key, val] = line.split(':', 2)
        result[trim(key)] = trim(val)

    result

#-------------------------------------------------------------------------------
trim = (string) ->
    string.replace(/^\s+|\s+$/g, '')

#-------------------------------------------------------------------------------
getFormData = (url, data) ->
    return data if data

    pattern = /.*?\?(.*?)(#.*)?$/
    match = url.match(pattern)
    return match[1] if match

    return ""

#-------------------------------------------------------------------------------
splitContentType = (contentType) ->
    pattern = /\s*(.*?)\s*(;\s*(.*))?\s*$/
    match = contentType.match(pattern)
    return [contentType, ""] unless match

    return [match[1], match[3]]

#-------------------------------------------------------------------------------
getXhrEventHandler = (xhr) ->
    ->
        nr = xhr.__weinreNetworkRequest__
        return unless nr

        try
            switch xhr.readyState
                when 2 then nr.handleHeadersReceived()
                when 3 then nr.handleLoading()
                when 4 then nr.handleDone()
        catch e
            # do nothing

