
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
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
      metrics.marginLeft    = fromPx(cStyle["margin-left"])
      metrics.marginRight   = fromPx(cStyle["margin-right"])
      metrics.marginTop     = fromPx(cStyle["margin-top"])
      metrics.marginBottom  = fromPx(cStyle["margin-bottom"])
      metrics.borderLeft    = fromPx(cStyle["border-left-width"])
      metrics.borderRight   = fromPx(cStyle["border-right-width"])
      metrics.borderTop     = fromPx(cStyle["border-top-width"])
      metrics.borderBottom  = fromPx(cStyle["border-bottom-width"])
      metrics.paddingLeft   = fromPx(cStyle["padding-left"])
      metrics.paddingRight  = fromPx(cStyle["padding-right"])
      metrics.paddingTop    = fromPx(cStyle["padding-top"])
      metrics.paddingBottom = fromPx(cStyle["padding-bottom"])

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