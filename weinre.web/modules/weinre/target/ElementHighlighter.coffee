
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

Binding = require('../common/Binding')
Weinre  = require('../common/Weinre')

#-------------------------------------------------------------------------------
module.exports = class ElementHighlighter

    ElementHighlighter::__defineGetter__("element", -> @boxMargin)

    constructor: ->
        @boxMargin  = document.createElement("div")
        @boxBorder  = document.createElement("div")
        @boxPadding = document.createElement("div")
        @boxContent = document.createElement("div")

        @boxMargin.appendChild  @boxBorder
        @boxBorder.appendChild  @boxPadding
        @boxPadding.appendChild @boxContent

        @boxMargin.style.backgroundColor  = "#FCC"
        @boxBorder.style.backgroundColor  = "#000"
        @boxPadding.style.backgroundColor = "#CFC"
        @boxContent.style.backgroundColor = "#CCF"

        @boxMargin.style.opacity       = @boxBorder.style.opacity       = @boxPadding.style.opacity       = @boxContent.style.opacity       = 0.6
        @boxMargin.style.position      = @boxBorder.style.position      = @boxPadding.style.position      = @boxContent.style.position      = "absolute"
        @boxMargin.style.borderWidth   = @boxBorder.style.borderWidth   = @boxPadding.style.borderWidth   = @boxContent.style.borderWidth   = "thin"
        @boxMargin.style.borderStyle   = @boxBorder.style.borderStyle   = @boxPadding.style.borderStyle   = @boxContent.style.borderStyle   = "solid"
        @boxMargin.__weinreHighlighter = @boxBorder.__weinreHighlighter = @boxPadding.__weinreHighlighter = @boxContent.__weinreHighlighter = true

        @boxMargin.style.display = "none"
        document.body.appendChild @boxMargin

    #---------------------------------------------------------------------------
    on: (element) ->
        return if null == element
        return unless element.nodeType == Node.ELEMENT_NODE

        @calculateMetrics element
        @boxMargin.style.display = "block"

    #---------------------------------------------------------------------------
    off: ->
        @boxMargin.style.display = "none"

    #---------------------------------------------------------------------------
    calculateMetrics: (element) ->
        metrics = getMetrics(element)

        @boxMargin.style.top     = metrics.y + "px"
        @boxMargin.style.left    = metrics.x + "px"
        @boxMargin.style.height  = metrics.height + "px"
        @boxMargin.style.width   = metrics.width + "px"
        @boxBorder.style.top     = metrics.marginTop + "px"
        @boxBorder.style.left    = metrics.marginLeft + "px"
        @boxBorder.style.bottom  = metrics.marginBottom + "px"
        @boxBorder.style.right   = metrics.marginRight + "px"
        @boxPadding.style.top    = metrics.borderTop + "px"
        @boxPadding.style.left   = metrics.borderLeft + "px"
        @boxPadding.style.bottom = metrics.borderBottom + "px"
        @boxPadding.style.right  = metrics.borderRight + "px"
        @boxContent.style.top    = metrics.paddingTop + "px"
        @boxContent.style.left   = metrics.paddingLeft + "px"
        @boxContent.style.bottom = metrics.paddingBottom + "px"
        @boxContent.style.right  = metrics.paddingRight + "px"

#-------------------------------------------------------------------------------
getMetrics = (element) ->
      result = {}
      left = 0
      top  = 0
      el   = element

      loop
          left += el.offsetLeft
          top += el.offsetTop
          break unless el = el.offsetParent

      result.x = left
      result.y = top

      cStyle = document.defaultView.getComputedStyle(element)

      result.width         = fromPx(cStyle["width"])
      result.height        = fromPx(cStyle["height"])
      result.marginLeft    = fromPx(cStyle["margin-left"])
      result.marginRight   = fromPx(cStyle["margin-right"])
      result.marginTop     = fromPx(cStyle["margin-top"])
      result.marginBottom  = fromPx(cStyle["margin-bottom"])
      result.borderLeft    = fromPx(cStyle["border-left-width"])
      result.borderRight   = fromPx(cStyle["border-right-width"])
      result.borderTop     = fromPx(cStyle["border-top-width"])
      result.borderBottom  = fromPx(cStyle["border-bottom-width"])
      result.paddingLeft   = fromPx(cStyle["padding-left"])
      result.paddingRight  = fromPx(cStyle["padding-right"])
      result.paddingTop    = fromPx(cStyle["padding-top"])
      result.paddingBottom = fromPx(cStyle["padding-bottom"])

      result.width  += result.marginLeft + result.marginRight  + result.borderRight  + result.paddingLeft + result.paddingRight
      result.height += result.marginTop  + result.marginBottom + result.borderBottom + result.paddingTop  + result.paddingBottom

      result.x -= result.marginLeft
      result.y -= result.marginTop

      result

#-------------------------------------------------------------------------------
fromPx = (string) ->
      parseInt string.replace(/px$/, "")

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
