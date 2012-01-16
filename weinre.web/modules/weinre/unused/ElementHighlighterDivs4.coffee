
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