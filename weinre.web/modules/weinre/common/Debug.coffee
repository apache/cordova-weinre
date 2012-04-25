
#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
module.exports = new class Debug

    #---------------------------------------------------------------------------
    constructor: ->
        @_printCalledArgs = {}

    #---------------------------------------------------------------------------
    log: (message) -> 
        console = window.console.__original || window.console
        console.log "#{@timeStamp()}: #{message}"

    #---------------------------------------------------------------------------
    logCall: (context, intf, method, args, message) ->
        if message
            message = ": #{message}"
        else
            message = ""
        
        signature = @signature(intf, method)
        printArgs = @_printCalledArgs[signature]
        
        if printArgs
            args = JSON.stringify(args,null,4)
        else
            args = ""
        
        @log "#{context} #{signature}(#{args})#{message}"

    #---------------------------------------------------------------------------
    logCallArgs: (intf, method) -> 
        @_printCalledArgs[@signature(intf, method)] = true

    #---------------------------------------------------------------------------
    signature: (intf, method) ->
        "#{intf}.#{method}"
    
    #---------------------------------------------------------------------------
    timeStamp: ->
        date = new Date()
        
        mins = "#{date.getMinutes()}"
        secs = "#{date.getSeconds()}"
        
        mins = "0#{mins}" if mins.length == 1
        secs = "0#{secs}" if secs.length == 1
        
        "#{mins}:#{secs}"
    