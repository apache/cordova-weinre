/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.application;

import java.io.IOException;
import java.util.Properties;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

import weinre.server.Utility;


//-------------------------------------------------------------------
public class GUIPreferences {
    static final private String PROPERTIES_FILE_NAME = "ui.properties";
    
    private Properties properties;
    
    //---------------------------------------------------------------
    public GUIPreferences() {
        super();

        properties = Utility.readPropertiesFile(PROPERTIES_FILE_NAME);
    }
    
    //---------------------------------------------------------------
    public JSONObject getPreference(String key) throws IOException {
        String val = properties.getProperty(key);
        if (null == val) return null;

        try {
            return new JSONObject(val);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
    }
    
    //---------------------------------------------------------------
    public void setPreference(String key, JSONObject json) {
        String val = json.toString();
        
        properties.setProperty(key, val);
        Utility.writePropertiesFile(PROPERTIES_FILE_NAME, properties);
    }

}
