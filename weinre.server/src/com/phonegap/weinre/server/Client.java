/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server;

import org.apache.wink.json4j.JSONArray;
import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

/**
 * 
 */
public class Client extends Connector {

    private Target connectedTarget;
    
    /**
     * 
     */
    public Client(Channel channel) {
        super(channel);
        _register();
    }

    /**
     * 
     */
    public boolean isClient() {
        return true;
    }
    
    /**
     * 
     */
    public Target getConnectedTarget() {
        return connectedTarget;
    }
    
    /**
     * 
     */
    protected void _connect(Target target) {
        if (null == target) return;
        
        Lock.lock();
        
        try {
            connectedTarget = target;
        }
        finally {
            Lock.unlock();
        }
    }
    
    /**
     * 
     */
    protected void _disconnect(Target target) {
        if (null == target) return;
        
        Lock.lock();
        
        try {
            connectedTarget = null;
        }
        finally {
            Lock.unlock();
        }
    }
    
    /**
     * 
     */
    public JSONObject getDescription() {
      JSONObject result = new JSONObject();
      
      try {
          result.put("id",                 getChannel().getName());
          result.put("hostName",           getChannel().getRemoteHost());
          result.put("connectedTargetIds", new JSONArray());
      } 
      catch (JSONException e) {
          throw new RuntimeException(e);
      }

      return result;
    }
    
}
