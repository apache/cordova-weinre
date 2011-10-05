/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright (c) 2010, 2011 IBM Corporation
 */

(function() {
    var InspectorFrontEndHostImpl = require("weinre/client/InspectorFrontendHostImpl")
    window.InspectorFrontendHost = new InspectorFrontEndHostImpl()
})()
