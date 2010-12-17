/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server.service;

import java.io.IOException;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

import com.phonegap.weinre.server.Channel;


/**
 * 
 */
public class WebInspectorControllerHandler extends InspectorBackend {

    /**
     * 
     */
    public WebInspectorControllerHandler() {
        super();
    }

    /**
     * 
     */
    public void getSettings(Channel channel, String callbackId) throws IOException {
        JSONObject settings = new JSONObject();
        
        try {
            settings.put("application", "{}");
            settings.put("session",     "{}");
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
        
        channel.sendCallback("WeinreClientEvents", callbackId, settings);
    }

    /**
     * 
     */
    public void getInspectorState(Channel channel, String callbackId) throws IOException {
        JSONObject state = new JSONObject();
        try {
            state.put("monitoringXHREnabled", false);
            state.put("pauseOnExceptionsState", false);
            state.put("resourceTrackingEnabled", false);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        channel.sendCallback("WeinreClientEvents", callbackId, state);
    }

    /**
     * 
     */
    public void storeLastActivePanel(Channel channel, String panelName, String callbackId) throws IOException {
        lastActivePanelName = panelName;

        channel.sendCallback("WeinreClientEvents", callbackId);
    }

}
