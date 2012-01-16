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

package weinre.server;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Properties;

//-------------------------------------------------------------------
public class Utility {

    static private int SequenceNumber = 1 + new SecureRandom().nextInt(Integer.MAX_VALUE - 1);

    //---------------------------------------------------------------
    private Utility() {}

    //---------------------------------------------------------------
    static public synchronized int getNextSequenceNumber() {
        int result = SequenceNumber;

        SequenceNumber = (result == Integer.MAX_VALUE) ? 1 : result + 1;

        return result;
    }

    //---------------------------------------------------------------
    static public String reverse(String string) {
        char[] responseChars = string.toCharArray();

        for (int i=0; i<responseChars.length/2; i++) {
            char tmp                                = responseChars[responseChars.length-i-1];
            responseChars[responseChars.length-i-1] = responseChars[i];
            responseChars[i]                        = tmp;
        }
        return String.valueOf(responseChars);
    }

    //---------------------------------------------------------------
    static public byte[] reverse(byte[] data, int offset, int length) {
        byte[] response = new byte[length];

        for (int i=0; i<length; i++) {
            response[i] = data[offset + length - i - 1];
        }

        return response;
    }

    //---------------------------------------------------------------
    static public Properties readPropertiesFile(String fileName) {
        Properties result = new Properties();

        String userHome = System.getProperty("user.home");
        if (null == userHome) {
            Main.warn("System property user.home not set!");
            return result;
        }

        File file = new File(new File(userHome, ".weinre"), fileName);

        if (!file.exists()) return result;

        FileReader fr = null;
        try {
            fr = new FileReader(file);
            result.load(fr);
        }
        catch (IOException e) {
            Main.warn("Exception reading '" + file.getAbsolutePath() + "': " + e);
        }
        finally {
            try { if (fr != null) fr.close(); } catch (Exception e) {}
        }

        // ya, Properties doesn't trim space off values
        for (String key: result.stringPropertyNames()) {
            String val = result.getProperty(key);
            result.setProperty(key, val.trim());
        }

        return result;
    }

    //---------------------------------------------------------------
    static public void writePropertiesFile(String fileName, Properties properties) {
        String userHome = System.getProperty("user.home");
        if (null == userHome) {
            Main.warn("System property user.home not set!");
            return;
        }

        File file = new File(userHome, ".weinre");
        if (!file.exists()) {
            if (!file.mkdir()) {
                Main.warn("unable to create directory ~/.weinre");
                return;
            }
        }

        if (!file.isDirectory()) {
            Main.warn("can't write ~/.weinre/" + fileName + " since ~/.weinre is not a directory");
            return;
        }

        file = new File(file, fileName);
        FileWriter fw = null;
        try {
            fw = new FileWriter(file);
            properties.store(fw, fileName);
        }
        catch (IOException e) {
            Main.warn("Exception writing '" + file.getAbsolutePath() + "': " + e);
        }
        finally {
            try { if (fw != null) fw.close(); } catch (Exception e) {}
        }
    }

}
