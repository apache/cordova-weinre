/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.apache.wink.json4j.JSONArray;
import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

/**
 * 
 */
public class Target extends Connector {

    private List<Client> connectedClients;
    private String       url;
    
    /**
     * 
     */
    public Target(Channel channel, String url) {
        super(channel);
        
        connectedClients = new ArrayList<Client>();
        this.url = url;
        _register();

    }
    
    /**
     * 
     */
    public String getURL() {
        return this.url;
    }
    
    /**
     * 
     */
    public boolean isTarget() {
        return true;
    }
    
    /**
     * 
     */
    public List<Client> getConnectedClients() {
        List<Client> result = new LinkedList<Client>();
        
        Lock.lock();
        try {
            result.addAll(connectedClients);
        }
        finally {
            Lock.unlock();
        }
        
        return result;
    }
    
    /**
     * 
     */
    protected void _connect(Client client) {
        if (null == client) return;
        
        Lock.lock();
        
        try {
            if (connectedClients.contains(client)) return;
        
            connectedClients.add(client);
        }
        finally {
            Lock.unlock();
        }
    }
    
    /**
     * 
     */
    protected void _disconnect(Client client) {
        if (null == client) return;
        
        Lock.lock();
        
        try {
            if (!connectedClients.contains(client)) return;

            connectedClients.remove(client);
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
            result.put("url",                this.url);
            result.put("connectedClientIds", new JSONArray());
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
        
        return result;
    }
    
    
}
