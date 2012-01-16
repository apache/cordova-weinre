
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

dt = require('./DOMTemplates')

#-------------------------------------------------------------------------------
module.exports = class ConnectorList

    constructor: (title) ->
        @connectors = {}

        @noneItem     = dt.LI("none")
        @ulConnectors = dt.UL(@noneItem)
        @div          = dt.DIV(dt.H1(title), @ulConnectors)

        @noneItem.addStyleClass "weinre-connector-item"

    #---------------------------------------------------------------------------
    getElement: ->
        @div

    #---------------------------------------------------------------------------
    add: (connector) ->
        return if @connectors[connector.channel]

        @connectors[connector.channel] = connector

        li = @getListItem(connector)
        li.addStyleClass "weinre-fadeable"

        @noneItem.style.display = "none"

        insertionPoint = @getConnectorInsertionPoint(connector)
        unless insertionPoint
            @ulConnectors.appendChild li
        else
            @ulConnectors.insertBefore li, insertionPoint

    #---------------------------------------------------------------------------
    get: (channel) ->
        @connectors[channel]

    #---------------------------------------------------------------------------
    getNewestConnectorChannel: (ignoring) ->
        newest = 0
        for connectorChannel of @connectors
            continue if connectorChannel == ignoring
            newest = connectorChannel if connectorChannel > newest

        return null if newest == 0
        newest

    #---------------------------------------------------------------------------
    getConnectorInsertionPoint: (connector) ->
        i = 0

        for childNode in @ulConnectors.childNodes
            continue if null == childNode.connectorChannel
            return childNode if childNode.connectorChannel < connector.channel

        null

    #---------------------------------------------------------------------------
    remove: (channel, fast) ->
        self = this

        element = @getConnectorElement(channel)
        return unless element

        connector = @connectors[channel]
        connector.closed = true if connector
        delete @connectors[channel]

        if fast
            @_remove element
        else
            @setState element, "closed"
            element.addStyleClass "weinre-fade"

            window.setTimeout (->
                self._remove element
            ), 5000

    #---------------------------------------------------------------------------
    _remove: (element) ->
        @ulConnectors.removeChild element
        @noneItem.style.display = "list-item" if @getConnectors().length == 0

    #---------------------------------------------------------------------------
    removeAll: () ->
        for connector in @getConnectors()
            @remove connector.channel, true

    #---------------------------------------------------------------------------
    getConnectors: () ->
        result = []

        for channel of @connectors
            continue unless @connectors.hasOwnProperty(channel)
            result.push @connectors[channel]

        result

    #---------------------------------------------------------------------------
    getConnectorElement: (channel) ->
        connector = @connectors[channel]
        return null unless connector
        connector.element

    #---------------------------------------------------------------------------
    setCurrent: (channel) ->
        for connector in @getConnectors()
            connector.element.removeStyleClass "current"

        element = @getConnectorElement(channel)
        return if null == element
        element.addStyleClass "current"

    #---------------------------------------------------------------------------
    setState: (channel, state) ->
        if typeof channel == "string"
            element = @getConnectorElement(channel)
        else
            element = channel

        return unless element
        element.removeStyleClass "error"
        element.removeStyleClass "closed"
        element.removeStyleClass "connected"
        element.removeStyleClass "not-connected"
        element.addStyleClass state

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
