/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package com.phonegap.weinre.server.service;

import java.io.IOException;

import org.apache.wink.json4j.JSONArray;

import com.phonegap.weinre.server.BasicService;
import com.phonegap.weinre.server.Channel;
import com.phonegap.weinre.server.Main;


/**
 * 
 */
public class WebInspectorBackendHandler extends BasicService {

    /**
     * 
     */
    public WebInspectorBackendHandler() {
        super();
    }

    /**
     * 
     */
    public void setInjectedScriptSource(Channel channel, String scriptSource, String callbackId) throws IOException {
        channel.sendCallback("WeinreClientEvents", callbackId);
    }

    /**
     * 
     */
    public void debug_dispatchOnInjectedScript(Channel channel, Number injectedScriptId, String methodName, String arguments, String callbackId) throws IOException {
        Main.debug("dispatchOnInjectedScript(" + methodName + ")");
        
        JSONArray args = new JSONArray();
        args.add(injectedScriptId);
        args.add(methodName);
        args.add(arguments);
        args.add(callbackId);
        __doesNotUnderstand(channel, "dispatchOnInjectedScript", args);
    }

}
