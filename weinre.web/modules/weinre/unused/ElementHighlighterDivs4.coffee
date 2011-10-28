
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

ElementHighlighter = require('./ElementHighlighter')

#-------------------------------------------------------------------------------
module.exports = class ElementHighlighterDivs4 extends ElementHighlighter

    #---------------------------------------------------------------------------
    createHighlighterElement: ->

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

        @boxMargin

    #---------------------------------------------------------------------------
    redraw: (metrics) ->

        @boxMargin.style.top     = metrics.y
        @boxMargin.style.left    = metrics.x
        @boxMargin.style.height  = metrics.height
        @boxMargin.style.width   = metrics.width
        @boxBorder.style.top     = metrics.marginTop
        @boxBorder.style.left    = metrics.marginLeft
        @boxBorder.style.bottom  = metrics.marginBottom
        @boxBorder.style.right   = metrics.marginRight
        @boxPadding.style.top    = metrics.borderTop
        @boxPadding.style.left   = metrics.borderLeft
        @boxPadding.style.bottom = metrics.borderBottom
        @boxPadding.style.right  = metrics.borderRight
        @boxContent.style.top    = metrics.paddingTop
        @boxContent.style.left   = metrics.paddingLeft
        @boxContent.style.bottom = metrics.paddingBottom
        @boxContent.style.right  = metrics.paddingRight

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)