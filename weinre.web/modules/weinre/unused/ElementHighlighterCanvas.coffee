
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
#---------------------------------------------------------------------------------

ElementHighlighter = require('./ElementHighlighter')

ColorMargin   =  'rgba(246, 178, 107, 0.66)'
ColorBorder   =  'rgba(255, 229, 153, 0.66)'
ColorPadding  =  'rgba(147, 196, 125, 0.55)'
ColorContent  =  'rgba(111, 168, 220, 0.66)'

#-------------------------------------------------------------------------------
module.exports = class ElementHighlighterCanvas extends ElementHighlighter

    #---------------------------------------------------------------------------
    createHighlighterElement: ->

        @canvas = document.createElement('canvas')
        @canvas.style.position = 'absolute'
        @canvas

    #---------------------------------------------------------------------------
    redraw: (m) ->

        @canvas.width  = m.width
        @canvas.height = m.height

        style = @canvas.style

        style.top     = m.y
        style.left    = m.x
        style.height  = m.height
        style.width   = m.width

        g = @canvas.getContext("2d")

        #--------------------------------------
        x = 0
        y = 0
        w = m.width
        h = m.height
        g.fillStyle = ColorMargin
        g.fillRect(x,y,w,h)

        #--------------------------------------
        x += m.marginLeft
        y += m.marginTop
        w -= m.marginLeft + m.marginRight
        h -= m.marginTop  + m.marginBottom

        g.fillStyle = ColorBorder
        g.clearRect(x,y,w,h)
        g.fillRect(x,y,w,h)

        #--------------------------------------
        x += m.borderLeft
        y += m.borderTop
        w -= m.borderLeft + m.borderRight
        h -= m.borderTop  + m.borderBottom

        g.fillStyle = ColorPadding
        g.clearRect(x,y,w,h)
        g.fillRect(x,y,w,h)

        #--------------------------------------
        x += m.paddingLeft
        y += m.paddingTop
        w -= m.paddingLeft + m.paddingRight
        h -= m.paddingTop  + m.paddingBottom

        g.fillStyle = ColorContent
        g.clearRect(x,y,w,h)
        g.fillRect(x,y,w,h)

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)