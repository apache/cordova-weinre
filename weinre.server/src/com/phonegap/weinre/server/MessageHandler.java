/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package com.phonegap.weinre.server;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import org.apache.wink.json4j.JSONArray;
import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

/**
 * 
 */
public class MessageHandler {

    /**
     * 
     */
    static public void start() {
        final MessageHandler messageHandler = new MessageHandler();
        
        Runnable runnable = new Runnable() {
            public void run() {
                while (true) {
                    try { 
                        messageHandler.handleMessages();
                        Thread.sleep(250); 
                    } 
                    catch(InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }
            }
        };
        
        Thread thread = new Thread(runnable, messageHandler.getClass().toString());
        thread.start();
    }
    
    /**
     * 
     */
    private MessageHandler() {
    }
    
    /**
     * 
     */
    private void handleMessages() throws InterruptedException {
        List<Channel> channels = ChannelManager.$.getChannels();
        
        for (Channel channel: channels) {
            List<String> requestss = channel.getRequests(0);
            
            for (String requests: requestss) {
                JSONArray acc;
                
                try {
                    acc = new JSONArray(requests);
                }
                catch (JSONException e) {
                    Main.warn("error parsing requests: " + e + ": '" + requests + "'");
                    continue;
                }
                
                int size = acc.length();
                for (int i=0; i<size; i++) {
                    JSONObject accRequest;
                    String request = "???";
                    try {
                        request = acc.getString(i);
                        accRequest = new JSONObject(request);
                    }
                    catch (JSONException e) {
                        Main.warn("error parsing request: " + e + ": '" + request + "'");
                        continue;
                    }
                        
                    String intfName;
                    String methodName;
                    JSONArray args;
                    try {
                        intfName = accRequest.getString("interface");
                        methodName = accRequest.getString("method");
                        args       = accRequest.getJSONArray("args");
                    } catch (JSONException e) {
                        throw new RuntimeException(e);
                    }
                    
                    if (null == intfName) {
                        Main.warn("no interface specified in request: " + request);
                        continue;
                    }
                    
                    if (null == methodName) {
                        Main.warn("no methodName specified in request: " + request);
                        continue;
                    }
                    
                    if (null == args) {
                        Main.warn("no args specified in request: " + request);
                        continue;
                    }
       
                    serviceMethodInvoker(channel, intfName, methodName, args);
                }
            }
        }
    }

    /**
     * 
     */
    @SuppressWarnings({ "rawtypes", "unchecked" })
    private void serviceMethodInvoker(Channel channel, String intfName, String methodName, JSONArray argsJSON) {
        Object service;
        String methodSignature = intfName + "." + methodName + "()";

        Main.debug(channel.getName() + ": recv " + methodSignature);
        
        try {
            service = channel.getService(intfName);
        }
        catch (RuntimeException e) {
            Main.warn("unable to get service object for: " + methodSignature + "; " + e);
            return;
        }
        
        Class serviceClass = service.getClass();
        
        List<Object> args = new ArrayList<Object>(argsJSON);
        
        for (Method method: serviceClass.getMethods()) {
            if (!method.getName().equals(methodName)) continue;
            
            if (method.getParameterTypes().length != args.size() + 1) {
                Main.warn("invalid number of parameters specified for : " + methodSignature);
                return;
            }
            args.add(0, channel);
            
            try {
                method.invoke(service, args.toArray());
            } 
            catch (IllegalArgumentException e) {
                Main.warn("illegal argument exception invoking : " + methodSignature + "; " + e);
            } 
            catch (IllegalAccessException e) {
                Main.warn("illegal access exception invoking : " + methodSignature + "; " + e);
            } 
            catch (InvocationTargetException e) {
                Throwable te = e.getTargetException();
                Main.warn("invocation target exception invoking : " + methodSignature + "; " + te);
                te.printStackTrace();
            }
            catch (RuntimeException e) {
                Main.warn("invocation runtime exception invoking : " + methodSignature + "; " + e);
            }
            
            return;
        }
        
        Method dnuMethod;
        try {
            dnuMethod = serviceClass.getMethod("__doesNotUnderstand", Channel.class, String.class, JSONArray.class);
        } 
        catch (SecurityException e) {
            Main.warn("security exception looking up method __doesNotUnderstand invoking : " + methodSignature + "; " + e);
            return;
        } 
        catch (NoSuchMethodException e) {
            Main.warn("no __doesNotUnderstand method found while invoking : " + methodSignature + "; " + e);
            return;
        }
        
        Object[] dnuArgs = new Object[3];
        dnuArgs[0] = channel;
        dnuArgs[1] = methodName;
        try {
            dnuArgs[2] = new JSONArray(args);
        } catch (JSONException e1) {
            throw new RuntimeException(e1);
        }
        
        try {
            dnuMethod.invoke(service, dnuArgs);
        } 
        catch (IllegalArgumentException e) {
            Main.warn("illegal argument exception invoking __doesNotUnderstand invoking: " + methodSignature + "; " + e);
        } 
        catch (IllegalAccessException e) {
            Main.warn("illegal access exception invoking __doesNotUnderstand invoking: " + methodSignature + "; " + e);
        } 
        catch (InvocationTargetException e) {
            Main.warn("invocation target exception invoking __doesNotUnderstand invoking: " + methodSignature + "; " + e);
        }
    }
    
}
