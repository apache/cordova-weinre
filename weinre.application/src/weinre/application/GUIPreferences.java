/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
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
