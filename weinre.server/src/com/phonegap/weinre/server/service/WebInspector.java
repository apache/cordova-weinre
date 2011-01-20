/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package com.phonegap.weinre.server.service;

import java.io.IOException;
import java.util.List;

import org.apache.wink.json4j.JSONArray;

import com.phonegap.weinre.server.Channel;
import com.phonegap.weinre.server.Connector;

/**
 * 
 */
public class WebInspector {

    /**
     * 
     */
    public WebInspector() {
        super();
    }
    
    /**
     * 
     */
    public void __doesNotUnderstand(Channel channel, String methodName, JSONArray args) throws IOException {
        Connector connector = channel.getConnector();
        List<Connector> connections = connector.getConnections();
        
        for (Connector connection: connections) {
            connection.getChannel().sendEvent("WebInspector", methodName, args.toArray());
        }
    }


}
