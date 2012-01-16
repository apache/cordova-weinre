
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

Ex = require('../common/Ex')

#-------------------------------------------------------------------------------
getElementFunction = (elementName) ->
      ->
          element = document.createElement(elementName)

          args = [].slice.call(arguments)
          for argument in args
              if argument.nodeType
                  addToElement_Node element, argument
              else if typeof argument == "string"
                  addToElement_String element, argument
              else if typeof argument == "object"
                  addToElement_Object element, argument
              else
                  throw new Ex(arguments, "invalid value passed to DOMTemplates.#{elementName}(): " + argument)

          element

#-------------------------------------------------------------------------------
addToElement_String = (element, aString) ->
      addToElement_Node element, document.createTextNode(aString)

#-------------------------------------------------------------------------------
addToElement_Node = (element, anElement) ->
      element.appendChild anElement

#-------------------------------------------------------------------------------
addToElement_Object = (element, anObject) ->
      for key of anObject
          continue unless anObject.hasOwnProperty(key)

          val = anObject[key]
          if key.substr(0, 1) == "$"
              actualKey = key.substr(1)
              element[actualKey] = val
          else
              element.setAttribute key, val

#-------------------------------------------------------------------------------
elementNames = 'H1 H2 H3 H4 H5 H6 UL OL DL LI DT DD SPAN DIV A B I TT P HR BR PRE IMG CANVAS TABLE TR TD FORM INPUT BUTTON SELECT OPTGROUP OPTION TEXTAREA'
elementNames = elementNames.split(' ')

for elementName in elementNames
    exports[elementName] = getElementFunction(elementName)
    exports[elementName].name        = "#{elementName}"
    exports[elementName].displayName = "#{elementName}"
    exports[elementName].signature   = "DOMTemplates.#{elementName}"
