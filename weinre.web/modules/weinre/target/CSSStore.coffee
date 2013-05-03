
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

IDGenerator = require('../common/IDGenerator')
Weinre      = require('../common/Weinre')

_elementMatchesSelector = null

#-------------------------------------------------------------------------------
module.exports = class CSSStore

    #---------------------------------------------------------------------------
    constructor: ->
        @styleSheetMap = {}
        @styleRuleMap  = {}
        @styleDeclMap  = {}
        @testElement   = document.createElement("div")

    #---------------------------------------------------------------------------
    getInlineStyle: (node) ->
        styleObject = @_buildMirrorForStyle(node.style, true)

        for cssProperty in styleObject.cssProperties
            cssProperty.status = "style"

        styleObject

    #---------------------------------------------------------------------------
    getComputedStyle: (node) ->
        return {} unless node
        return {} unless node.nodeType == Node.ELEMENT_NODE

        styleObject = @_buildMirrorForStyle(window.getComputedStyle(node), false)
        styleObject

    #---------------------------------------------------------------------------
    getMatchedCSSRules: (node) ->
        result = []

        try 
            for styleSheet in document.styleSheets
                continue unless styleSheet.cssRules

                for cssRule in styleSheet.cssRules
                    continue unless _elementMatchesSelector(node, cssRule.selectorText)
                    object = {}
                    object.ruleId = @_getStyleRuleId(cssRule)
                    object.selectorText = cssRule.selectorText
                    object.style = @_buildMirrorForStyle(cssRule.style, true)
                    result.push object
        catch err
            return result

        result

    #---------------------------------------------------------------------------
    getStyleAttributes: (node) ->
        result = {}
        result

    #---------------------------------------------------------------------------
    getPseudoElements: (node) ->
        result = []
        result

    #---------------------------------------------------------------------------
    setPropertyText: (styleId, propertyIndex, text, overwrite) ->
        styleDecl = Weinre.cssStore._getStyleDecl(styleId)

        unless styleDecl
          Weinre.logWarning "requested style not available: " + styleId
          return null

        mirror = styleDecl.__weinre__mirror
        unless mirror
          Weinre.logWarning "requested mirror not available: " + styleId
          return null

        properties = mirror.cssProperties
        propertyMirror = @_parseProperty(text)

        if null == propertyMirror
          @_removePropertyFromMirror mirror, propertyIndex
          properties = mirror.cssProperties

        else
          @_removePropertyFromMirror mirror, propertyIndex
          properties = mirror.cssProperties
          propertyIndices = {}
          i = 0

          while i < properties.length
            propertyIndices[properties[i].name] = i
            i++
          i = 0

          while i < propertyMirror.cssProperties.length
            if propertyIndices[propertyMirror.cssProperties[i].name]?
              properties[propertyIndices[propertyMirror.cssProperties[i].name]] = propertyMirror.cssProperties[i]
            else
              properties.push propertyMirror.cssProperties[i]
            i++

          for key of propertyMirror.shorthandValues
            mirror.shorthandValues[key] = propertyMirror.shorthandValues[key]

        properties.sort compare = (p1, p2) ->
          if p1.name < p2.name
            -1
          else if p1.name > p2.name
            1
          else
            0

        @_setStyleFromMirror styleDecl
        mirror

    #---------------------------------------------------------------------------
    _removePropertyFromMirror: (mirror, index) ->
        properties = mirror.cssProperties
        return if index >= properties.length
        property = properties[index]
        properties[index] = null

        if mirror.shorthandValues[property.name]
            delete mirror.shorthandValues[property.name]

            i = 0

            while i < properties.length
                if properties[i]
                    if properties[i].shorthandName == property.name
                        properties[i] = null
                i++

        newProperties = []
        i = 0

        while i < properties.length
            newProperties.push properties[i] if properties[i]
            i++

        mirror.cssProperties = newProperties

    #---------------------------------------------------------------------------
    toggleProperty: (styleId, propertyIndex, disable) ->
        styleDecl = Weinre.cssStore._getStyleDecl(styleId)
        unless styleDecl
            Weinre.logWarning "requested style not available: " + styleId
            return null

        mirror = styleDecl.__weinre__mirror
        unless mirror
            Weinre.logWarning "requested mirror not available: " + styleId
            return null

        cssProperty = mirror.cssProperties[propertyIndex]
        unless cssProperty
            Weinre.logWarning "requested property not available: #{styleId}: " + propertyIndex
            return null

        if disable
            cssProperty.status = "disabled"
        else
            cssProperty.status = "active"

        @_setStyleFromMirror styleDecl
        mirror

    #---------------------------------------------------------------------------
    _setStyleFromMirror: (styleDecl) ->
        cssText = []
        cssProperties = styleDecl.__weinre__mirror.cssProperties
        cssText = ""

        for property in cssProperties
            continue unless property.parsedOk
            continue if property.status == "disabled"
            continue if property.shorthandName

            cssText += property.name + ": " + property.value
            if property.priority == "important"
                cssText += " !important; "
            else
                cssText += "; "

        styleDecl.cssText = cssText

    #---------------------------------------------------------------------------
    _buildMirrorForStyle: (styleDecl, bind) ->
        result =
          properties: {}
          cssProperties: []

        return result unless styleDecl
        if bind
          result.styleId = @_getStyleDeclId(styleDecl)
          styleDecl.__weinre__mirror = result

        result.properties.width = styleDecl.getPropertyValue("width") or ""
        result.properties.height = styleDecl.getPropertyValue("height") or ""
        result.cssText = styleDecl.cssText
        result.shorthandValues = {}

        properties = []
        if styleDecl
          i = 0

          while i < styleDecl.length
            property = {}
            name = styleDecl.item(i)
            property.name          = name
            property.priority      = styleDecl.getPropertyPriority(name)
            property.implicit      = if (typeof styleDecl.isPropertyImplicit != "undefined") then styleDecl.isPropertyImplicit(name) else true
            property.shorthandName = if (typeof styleDecl.getPropertyShorthand != "undefined") then (styleDecl.getPropertyShorthand(name) or "") else ""
            property.status        = (if property.shorthandName then "style" else "active")
            property.parsedOk      = true
            property.value         = styleDecl.getPropertyValue(name)
            properties.push property

            if property.shorthandName
              shorthandName = property.shorthandName

              unless result.shorthandValues[shorthandName]
                result.shorthandValues[shorthandName] = styleDecl.getPropertyValue(shorthandName)
                property = {}
                property.name          = shorthandName
                property.priority      = styleDecl.getPropertyPriority(shorthandName)
                property.implicit      = styleDecl.isPropertyImplicit(shorthandName)
                property.shorthandName = ""
                property.status        = "active"
                property.parsedOk      = true
                property.value         = styleDecl.getPropertyValue(name)
                properties.push property
            i++

        properties.sort (p1, p2) ->
          if p1.name < p2.name
            -1
          else if p1.name > p2.name
            1
          else
            0

        result.cssProperties = properties
        result

    #---------------------------------------------------------------------------
    _parseProperty: (string) ->
        testStyleDecl = @testElement.style

        try
            testStyleDecl.cssText = string
            unless testStyleDecl.cssText == ""
                return @_buildMirrorForStyle(testStyleDecl, false)

        propertyPattern = /\s*(.+)\s*:\s*(.+)\s*(!important)?\s*;/
        match = propertyPattern.exec(string)
        return null unless match

        match[3] = (if (match[3] == "!important") then "important" else "")

        property = {}
        property.name          = match[1]
        property.priority      = match[3]
        property.implicit      = true
        property.shorthandName = ""
        property.status        = "inactive"
        property.parsedOk      = false
        property.value         = match[2]

        result = {}
        result.width           = 0
        result.height          = 0
        result.shorthandValues = 0
        result.cssProperties   = [ property ]

        result

    #---------------------------------------------------------------------------
    _getStyleSheet: (id) ->
        _getMappableObject id, @styleSheetMap

    #---------------------------------------------------------------------------
    _getStyleSheetId: (styleSheet) ->
        _getMappableId styleSheet, @styleSheetMap

    #---------------------------------------------------------------------------
    _getStyleRule: (id) ->
        _getMappableObject id, @styleRuleMap

    #---------------------------------------------------------------------------
    _getStyleRuleId: (styleRule) ->
        _getMappableId styleRule, @styleRuleMap

    #---------------------------------------------------------------------------
    _getStyleDecl: (id) ->
        _getMappableObject id, @styleDeclMap

    #---------------------------------------------------------------------------
    _getStyleDeclId: (styleDecl) ->
        _getMappableId styleDecl, @styleDeclMap

#-------------------------------------------------------------------------------
_getMappableObject = (id, map) ->
      map[id]

#-------------------------------------------------------------------------------
_getMappableId = (object, map) ->
      IDGenerator.getId object, map

#-------------------------------------------------------------------------------
_mozMatchesSelector = (element, selector) ->
      return false unless element.mozMatchesSelector
      element.mozMatchesSelector selector

#-------------------------------------------------------------------------------
_webkitMatchesSelector = (element, selector) ->
      return false unless element.webkitMatchesSelector
      element.webkitMatchesSelector selector

#-------------------------------------------------------------------------------
_msMatchesSelector = (element, selector) ->
      return false unless element.msMatchesSelector
      element.msMatchesSelector selector

#-------------------------------------------------------------------------------
_fallbackMatchesSelector = (element, selector) ->
      false
#-------------------------------------------------------------------------------
if      (Element.prototype.webkitMatchesSelector)
    _elementMatchesSelector = _webkitMatchesSelector

else if (Element.prototype.mozMatchesSelector)
    _elementMatchesSelector = _mozMatchesSelector

else if (Element.prototype.msMatchesSelector)
    _elementMatchesSelector = _msMatchesSelector
else
    _elementMatchesSelector = _fallbackMatchesSelector

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
