/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package com.phonegap.weinre.server;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

/**
 * 
 */
public class Channel {
    
    private String                pathPrefix;
    private String                name;
    private MessageQueue<String>  requestQueue;
    private MessageQueue<String>  responseQueue;
    private boolean               isClosed;
    private Connector             connector;
    private long                  lastRead;
    private Map<String,Object>    serviceMap;
    private String                remoteHost;
    private String                remoteAddress;
    
    /**
     * 
     */
    public Channel(String pathPrefix, String name, String remoteHost, String remoteAddress) {
        this.pathPrefix         = pathPrefix;
        this.name               = name;
        this.remoteHost         = remoteHost;
        this.remoteAddress      = remoteAddress;
        this.requestQueue       = new MessageQueue<String>();
        this.responseQueue      = new MessageQueue<String>();
        this.isClosed           = false;
        this.connector          = null;
        this.serviceMap         = new HashMap<String,Object>();
        this.lastRead           = System.currentTimeMillis();
    }

    /**
     * 
     */
    public Connector getConnector() {
        return connector;
    }
    
    /**
     * 
     */
    public String getRemoteHost() {
        return remoteHost;
    }
    
    /**
     * 
     */
    public String getRemoteAddress() {
        return remoteAddress;
    }
    
    /**
     * 
     */
    protected void _setConnector(Connector connector) {
        this.connector = connector;
    }
    
    /**
     * 
     */
    public void sendCallback(String intfName, String callbackId, Object... args) throws IOException {
        if (callbackId == null) return;
        
        List<Object> innerArgs = new ArrayList<Object>();
        innerArgs.add(callbackId);
        innerArgs.add(Arrays.asList(args));
        
        sendEvent(intfName, "sendCallback", innerArgs.toArray());
    }
    
    /**
     * 
     */
    public void sendEvent(String intfName, String methodName, Object... args) {
        Main.debug(getName() + ": send " + intfName + "." + methodName + "()");
        
        JSONObject response = new JSONObject();
        
        String responseString;
        try {
            response.put("interface", intfName);
            response.put("method", methodName);
            
            List<Object> passedArgs = new ArrayList<Object>(Arrays.asList(args));
            
            response.put("args", passedArgs);

            responseString = response.toString();
        }
        catch (JSONException e) {
            Main.warn("IOException serializing message for " + intfName + "." + methodName);
            return;
        }
        
        this.postResponse(responseString);
    }
    
    /**
     * 
     */
    public Object getService(String name) {
        try {
            return getService_(name);
        }
        catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        catch (InstantiationException e) {
            throw new RuntimeException(e);
        }
        catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * @throws IllegalAccessException 
     * @throws InstantiationException 
     * 
     */
    @SuppressWarnings("rawtypes")
    private Object getService_(String name) throws ClassNotFoundException, InstantiationException, IllegalAccessException {
        Object result = serviceMap.get(name);
        if (null != result) return result;
        
        String klassName = "com.phonegap.weinre.server.service." + name;
        Class klass = Class.forName(klassName);
        if (null == klass) throw new ClassNotFoundException("class not found: " + klassName);
        
        result = klass.newInstance();
        return result;
    }
    
    /**
     * 
     */
    public void close() {
        isClosed = true;
        requestQueue.shutdown();
        responseQueue.shutdown();
        
        ChannelManager.$.deregisterChannel(name);
    }
    
    /**
     * 
     */
    public boolean isClosed() {
        return isClosed;
    }
    
    /**
     * 
     */
    public String getPathPrefix() {
        return pathPrefix;
    }
    
    /**
     * 
     */
    public String getName() {
        return name;
    }
    
    /**
     * 
     */
    public long getLastRead() {
        return lastRead;
    }
    
    /**
     * 
     */
    public void updateLastRead() {
        lastRead = System.currentTimeMillis();
    }
    
    /**
     * 
     */
    public void postRequest(String json) {
        if (isClosed()) return;
        
        requestQueue.add(json);
    }

    /**
     * 
     */
    public void postResponse(String json) {
        if (isClosed()) return;
        
        responseQueue.add(json);
    }

    /**
     * 
     */
    public List<String> getRequests(int timeoutSeconds) throws InterruptedException {
        if (isClosed()) return new LinkedList<String>();
        
        List<String> result = requestQueue.getAll(timeoutSeconds, TimeUnit.SECONDS);

        return result;
    }

    /**
     * 
     */
    public List<String> getResponses(int timeoutSeconds) throws InterruptedException {
        if (isClosed()) return new LinkedList<String>();
        
        List<String> result = responseQueue.getAll(timeoutSeconds, TimeUnit.SECONDS);

        return result;
    }

    /**
     * 
     */
    public String toString() {
        return getClass().getName() + "{" + pathPrefix + ":" + name + "}";
    }
}
