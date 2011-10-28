
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

ElementHighlighter = require('./ElementHighlighter')

# from Web Inspector
ColorMargin   =  'rgba(246, 178, 107, 0.66)'
ColorBorder   =  'rgba(255, 229, 153, 0.66)'
ColorPadding  =  'rgba(147, 196, 125, 0.55)'
ColorContent  =  'rgba(111, 168, 220, 0.66)'

# overrides
ColorBorder   =  'rgba(255, 255, 153, 0.40)'
ColorPadding  =  'rgba(  0, 255,   0, 0.20)'
ColorContent  =  'rgba(  0,   0, 255, 0.30)'

#-------------------------------------------------------------------------------
module.exports = class ElementHighlighterDivs2 extends ElementHighlighter

    #---------------------------------------------------------------------------
    createHighlighterElement: ->

        @hElement1 = document.createElement("weinreHighlighter")
        @hElement1.style.position = 'absolute'
        @hElement1.style.overflow = 'hidden'

        @hElement2 = document.createElement("weinreHighlighter")
        @hElement2.style.position = 'absolute'
        @hElement2.style.display  = 'block'
        @hElement2.style.overflow = 'hidden'

        @hElement1.appendChild @hElement2

        @hElement1.style.borderTopStyle    = 'solid'
        @hElement1.style.borderLeftStyle   = 'solid'
        @hElement1.style.borderBottomStyle = 'solid'
        @hElement1.style.borderRightStyle  = 'solid'
        @hElement1.style.borderTopColor    = ColorMargin
        @hElement1.style.borderLeftColor   = ColorMargin
        @hElement1.style.borderBottomColor = ColorMargin
        @hElement1.style.borderRightColor  = ColorMargin
        @hElement1.style.backgroundColor   = ColorBorder

        @hElement2.style.borderTopStyle    = 'solid'
        @hElement2.style.borderLeftStyle   = 'solid'
        @hElement2.style.borderBottomStyle = 'solid'
        @hElement2.style.borderRightStyle  = 'solid'
        @hElement2.style.borderTopColor    = ColorPadding
        @hElement2.style.borderLeftColor   = ColorPadding
        @hElement2.style.borderBottomColor = ColorPadding
        @hElement2.style.borderRightColor  = ColorPadding
        @hElement2.style.backgroundColor   = ColorContent

        @hElement1.style.outline           = 'black solid thin'

        @hElement1

    #---------------------------------------------------------------------------
    redraw: (metrics) ->

        @hElement1.style.top               = px metrics.y
        @hElement1.style.left              = px metrics.x
        @hElement1.style.height            = px metrics.height
        @hElement1.style.width             = px metrics.width

        @hElement1.style.borderTopWidth    = px metrics.marginTop
        @hElement1.style.borderLeftWidth   = px metrics.marginLeft
        @hElement1.style.borderBottomWidth = px metrics.marginBottom
        @hElement1.style.borderRightWidth  = px metrics.marginRight

        @hElement2.style.top               = px metrics.borderTop
        @hElement2.style.left              = px metrics.borderLeft
        @hElement2.style.bottom            = px metrics.borderBottom
        @hElement2.style.right             = px metrics.borderRight

        @hElement2.style.borderTopWidth    = px metrics.paddingTop
        @hElement2.style.borderLeftWidth   = px metrics.paddingLeft
        @hElement2.style.borderBottomWidth = px metrics.paddingBottom
        @hElement2.style.borderRightWidth  = px metrics.paddingRight

#-------------------------------------------------------------------------------
px = (value) ->
    "#{value}px"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)