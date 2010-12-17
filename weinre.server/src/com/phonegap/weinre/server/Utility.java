/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server;

import java.security.SecureRandom;

/**
 * 
 */
public class Utility {
    
    static private int SequenceNumber = 1 + new SecureRandom().nextInt(Integer.MAX_VALUE - 1);

    /**
     * class may not be instantiated
     */
    private Utility() {}

    /**
     * 
     */
    static public synchronized int getNextSequenceNumber() {
        int result = SequenceNumber;
        
        SequenceNumber = (result == Integer.MAX_VALUE) ? 1 : result + 1;
        
        return result;
    }
    
    /**
     * 
     */
    static public String reverse(String string) {
        char[] responseChars = string.toCharArray();
        
        for (int i=0; i<responseChars.length/2; i++) {
            char tmp                                = responseChars[responseChars.length-i-1];
            responseChars[responseChars.length-i-1] = responseChars[i];
            responseChars[i]                        = tmp;
        }
        return String.valueOf(responseChars);
    }
    
    /**
     * 
     */
    static public byte[] reverse(byte[] data, int offset, int length) {
        byte[] response = new byte[length];
        
        for (int i=0; i<length; i++) {
            response[i] = data[offset + length - i - 1];
        }

        return response;
    }
    
}
