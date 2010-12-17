/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server.service;

import java.io.IOException;
import java.util.List;

import com.phonegap.weinre.server.Channel;
import com.phonegap.weinre.server.ChannelManager;
import com.phonegap.weinre.server.Main;
import com.phonegap.weinre.server.Target;

/**
 * 
 */
public class WeinreTargetCommands {

    /**
     * 
     */
    public void registerTarget(Channel channel, String url, String callbackId) throws IOException {
        Target target = new Target(channel, url);
        
        channel.sendCallback("WeinreTargetEvents", callbackId, target.getName());
    }
    
    /**
     * 
     */
    @SuppressWarnings("unchecked")
    public void sendClientCallback(Channel channel, String clientCallbackId, Object args, String callbackId) throws IOException {
        Object[] argsArray;
        if (null == args) 
            argsArray = new Object[0];
        else 
            argsArray = ((List<Object>) args).toArray();
        
        // the channel to send the callback to is embedded in the callbackId
        String callbackConnectorId = getCallbackConnectorId(clientCallbackId);
        if (null == callbackConnectorId) {
            Main.warn(getClass().getName() + ".sendClientCallback() sent with invalid callbackId: " + clientCallbackId);
            return;
        }
        
        channel = ChannelManager.$.getChannel(callbackConnectorId);
        if (null == channel) {
            // indication that channel was closed; this message may generate a lot of noise
            Main.warn(getClass().getName() + ".sendClientCallback() unable to find channel : " + callbackConnectorId);
            return;
        }

        channel.sendCallback("WeinreClientEvents", clientCallbackId, argsArray);
    }
    
    /**
     * 
     */
    private String getCallbackConnectorId(String callbackId) {
        int index = callbackId.indexOf("::");
        return callbackId.substring(0, index);
    }
}
