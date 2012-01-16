
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

StackTrace = require('./StackTrace')

#-------------------------------------------------------------------------------
module.exports = class Ex

    #---------------------------------------------------------------------------
    @catching: (func) ->
        try
            func.call(this)
        catch e
            console.log "runtime error: #{e}"
            StackTrace.dump arguments

    #---------------------------------------------------------------------------
    constructor: (args, message) ->
        if not args or not args.callee
            throw Ex(arguments, "first parameter must be an Arguments object")

        StackTrace.dump args
        message = "threw error: " + message if message instanceof Error
        message = prefix(args, message)
        message

#-------------------------------------------------------------------------------
prefix = (args, string) ->
      return args.callee.signature   + ": " + string if args.callee.signature
      return args.callee.displayName + ": " + string if args.callee.displayName
      return args.callee.name        + ": " + string if args.callee.name

      "<anonymous>" + ": " + string

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
