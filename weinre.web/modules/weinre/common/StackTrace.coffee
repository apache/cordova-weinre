
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

module.exports = class StackTrace

    constructor: (args) ->
        if not args or not args.callee
            throw Error("first parameter to #{arguments.callee.signature} must be an Arguments object")

        @trace = getTrace(args)

    #---------------------------------------------------------------------------
    @dump: (args) ->
        args = args or arguments
        stackTrace = new StackTrace(args)
        stackTrace.dump()

    #---------------------------------------------------------------------------
    dump: ->
        console.log "StackTrace:"
        for frame in @trace
            console.log "    " + frame

#-------------------------------------------------------------------------------
getTrace = (args) ->
      result = []
      visitedFuncs = []
      func = args.callee

      while func
          if func.signature
              result.push func.signature
          else if func.displayName
              result.push func.displayName
          else if func.name
              result.push func.name
          else
              result.push "<anonymous>"

          unless -1 == visitedFuncs.indexOf(func)
              result.push "... recursion"
              return result

          visitedFuncs.push func
          try
              func = func.caller
          catch err 
              func = null

      result

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
