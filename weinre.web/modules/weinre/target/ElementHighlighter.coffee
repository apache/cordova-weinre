
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

canvasAvailable           = null
highlighterClass          = null
currentHighlighterElement = null

#-------------------------------------------------------------------------------
module.exports = class ElementHighlighter

    #---------------------------------------------------------------------------
    @create: ->
        highlighterClass ?= require('./ElementHighlighterDivs2')

        new highlighterClass()

    #---------------------------------------------------------------------------
    constructor: ->
        @hElement = @createHighlighterElement()
        @hElement.__weinreHighlighter = true
        @hElement.style.display = "none"
        @hElement.style.zIndex  = 10 * 1000 * 1000

        if currentHighlighterElement
            document.body.removeChild currentHighlighterElement

        currentHighlighterElement = @hElement

        document.body.appendChild @hElement

    #---------------------------------------------------------------------------
    on: (element) ->
        return if null == element
        return unless element.nodeType == Node.ELEMENT_NODE

        @redraw getMetricsForElement(element)

        @hElement.style.display = "block"

    #---------------------------------------------------------------------------
    off: ->
        @hElement.style.display = "none"

#-------------------------------------------------------------------------------
getMetricsForElement = (element) ->
      metrics = {}

      left = 0
      top  = 0
      el   = element

      loop
          left += el.offsetLeft
          top += el.offsetTop
          break unless el = el.offsetParent

      metrics.x = left
      metrics.y = top

      cStyle = document.defaultView.getComputedStyle(element)

      metrics.width         = element.offsetWidth
      metrics.height        = element.offsetHeight
      metrics.marginLeft    = fromPx(cStyle["margin-left"] || cStyle["marginLeft"])
      metrics.marginRight   = fromPx(cStyle["margin-right"] || cStyle["marginRight"])
      metrics.marginTop     = fromPx(cStyle["margin-top"] || cStyle["marginTop"])
      metrics.marginBottom  = fromPx(cStyle["margin-bottom"] || cStyle["marginBottom"])
      metrics.borderLeft    = fromPx(cStyle["border-left-width"] || cStyle["borderLeftWidth"])
      metrics.borderRight   = fromPx(cStyle["border-right-width"] || cStyle["borderRightWidth"])
      metrics.borderTop     = fromPx(cStyle["border-top-width"] || cStyle["borderTopWidth"])
      metrics.borderBottom  = fromPx(cStyle["border-bottom-width"] || cStyle["borderBottomWidth"])
      metrics.paddingLeft   = fromPx(cStyle["padding-left"] || cStyle["paddingLeft"])
      metrics.paddingRight  = fromPx(cStyle["padding-right"] || cStyle["paddingRight"])
      metrics.paddingTop    = fromPx(cStyle["padding-top"] || cStyle["paddingTop"])
      metrics.paddingBottom = fromPx(cStyle["padding-bottom"] || cStyle["paddingBottom"])

      metrics.x -= metrics.marginLeft
      metrics.y -= metrics.marginTop

      metrics

#-------------------------------------------------------------------------------
fromPx = (string) ->
      parseInt string.replace(/px$/, "")

#-------------------------------------------------------------------------------
supportsCanvas = () ->
    element = document.createElement('canvas')
    return false unless element.getContext
    return true if element.getContext('2d')
    return false

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)