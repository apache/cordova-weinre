
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
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
