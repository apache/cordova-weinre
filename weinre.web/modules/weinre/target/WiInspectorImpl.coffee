
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

Weinre   = require('../common/Weinre')
Timeline = require('../target/Timeline')

#-------------------------------------------------------------------------------
module.exports = class WiInspectorImpl

    constructor: ->

    #---------------------------------------------------------------------------
    reloadPage: (callback) ->
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback
        window.location.reload()

    #---------------------------------------------------------------------------
    highlightDOMNode: (nodeId, callback) ->
        node = Weinre.nodeStore.getNode(nodeId)

        unless node
            Weinre.logWarning arguments.callee.signature + " passed an invalid nodeId: " + nodeId
            return

        Weinre.elementHighlighter.on node
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    hideDOMNodeHighlight: (callback) ->
        Weinre.elementHighlighter.off()
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    startTimelineProfiler: (callback) ->
        Timeline.start()
        Weinre.wi.TimelineNotify.timelineProfilerWasStarted()
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

    #---------------------------------------------------------------------------
    stopTimelineProfiler: (callback) ->
        Timeline.stop()
        Weinre.wi.TimelineNotify.timelineProfilerWasStopped()
        Weinre.WeinreTargetCommands.sendClientCallback callback if callback

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
