
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2011 IBM Corporation
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
        sourceString = @xhr.responseText
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

    [contentType, encoding] = splitContentType(contentType)

    headers = getHeaders(xhr)

    return {
        mimeType: contentType
        expectedContentLength: contentType
        textEncodingName:      encoding
        httpStatusCode:        xhr.status
        httpStatusText:        xhr.statusText
        httpHeaderFields:      headers
        connectionReused:      false
        connectionID:          0
        wasCached:             false
    }

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

        switch xhr.readyState
            when 2 then nr.handleHeadersReceived()
            when 3 then nr.handleLoading()
            when 4 then nr.handleDone()

