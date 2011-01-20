/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server.service;

import java.io.IOException;
import java.util.Properties;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

import com.phonegap.weinre.server.Channel;
import com.phonegap.weinre.server.Utility;


/**
 * 
 */
public class WebInspectorControllerHandler extends InspectorBackend {

    static final private String AppKey       = "applicationSettings";
    static final private String SesKey       = "sessionSettings";
    static final private String SettingsName = "client-settings.properties";
    
    private Properties settings;
    
    /**
     * 
     */
    public WebInspectorControllerHandler() {
        super();
        
        readSettings();
    }

    /**
     * 
     */
    public void getSettings(Channel channel, String callbackId) throws IOException {

        JSONObject settingsResult = new JSONObject();
        
        try {
            settingsResult.put("application", settings.getProperty(AppKey));
            settingsResult.put("session",     settings.getProperty(SesKey));
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
        
        channel.sendCallback("WeinreClientEvents", callbackId, settings);
    }

    /**
     * 
     */
    public void saveApplicationSettings(Channel channel, String settingsString, String callbackId) throws IOException {
        settings.setProperty(AppKey, settingsString);
        writeSettings();
        
        channel.sendCallback("WeinreClientEvents", callbackId, settings);
    }
    
    /**
     * 
     */
    public void saveSessionSettings(Channel channel, String settingsString, String callbackId) throws IOException {
        settings.setProperty(SesKey, settingsString);
        writeSettings();
        
        channel.sendCallback("WeinreClientEvents", callbackId, settings);
    }

    /**
     * 
     */
    private void readSettings() {
        settings = Utility.readPropertiesFile(SettingsName);
        
        if (!settings.containsKey(AppKey)) settings.setProperty(AppKey, "{}");
        if (!settings.containsKey(SesKey)) settings.setProperty(SesKey, "{}");
    }

    /**
     * 
     */
    private void writeSettings() {
        Utility.writePropertiesFile(SettingsName, settings);
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
