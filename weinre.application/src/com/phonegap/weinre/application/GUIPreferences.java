/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.application;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Properties;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;
import org.eclipse.swt.widgets.Shell;

import com.phonegap.weinre.server.Main;

/**
 * 
 */
public class GUIPreferences {
    private Properties properties;
    private String     fileName;
    
    /**
     * 
     */
    public GUIPreferences() {
        super();

        properties = new Properties();
        fileName   = null;
        
        String userHome = System.getProperty("user.home");
        if (null == userHome) {
            Main.warn("System property user.home not set!");
            return;
        }
        
        File dir = new File(userHome, ".weinre");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        
        File file = new File(dir, "ui.properties");
        fileName = file.getAbsolutePath();
        
        if (!file.exists()) return;
        
        loadFromFile();
    }

    /**
     * 
     */
    public String getBoundsKey(Shell shell, String name) {
        return "bounds-" + name + "-" + ShellSizeTracker.getMonitorSetupKey(shell.getDisplay());        
    }
    
    /**
     * 
     */
    public void loadFromFile() {
        properties.clear();
        
        try {
            properties.load(new FileReader(fileName));
        }
        catch (IOException e) {
            Main.warn("IOException reading '" + fileName + "': " + e);
        }
    }

    /**
     * 
     */
    public void saveToFile() {
        if (null == fileName) return;
        
        try {
            properties.store(new FileWriter(fileName), "ui settings");
        }
        catch (IOException e) {
            Main.warn("IOException writing '" + fileName + "': " + e);
        }
    }
    
    /**
     * 
     */
    public String getPreference(String key) {
        if (null == properties) loadFromFile();
        return properties.getProperty(key);
    }
    
    /**
     * 
     */
    public JSONObject getPreferenceFromJSON(String key) throws IOException {
        String val = getPreference(key);
        if (null == val) return null;

        try {
            return new JSONObject(val);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 
     */
    public void setPreference(String key, String val) {
        properties.setProperty(key, val);
    }

    /**
     * 
     */
    public void setPreference(String key, JSONObject json) throws IOException {
        String val = json.toString();
        
        properties.setProperty(key, val);
    }

}
