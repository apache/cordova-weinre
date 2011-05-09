/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server.service;

import java.io.IOException;
import java.util.List;

import org.apache.wink.json4j.JSONObject;

import weinre.server.Channel;
import weinre.server.ChannelManager;
import weinre.server.Main;
import weinre.server.Target;

//-------------------------------------------------------------------
public class WeinreTargetCommands {

    //---------------------------------------------------------------
    public void registerTarget(Channel channel, String url, String callbackId) throws IOException {
        Target target = new Target(channel, url);
        
        JSONObject description = target.getDescription();
        
        channel.sendCallback("WeinreTargetEvents", callbackId, description);
    }
    
    //---------------------------------------------------------------
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
    
    //---------------------------------------------------------------
    public void logDebug(Channel channel, String message, String callbackId) {
        Main.debug("target " + channel.getName() + ": " + message);
    }

    //---------------------------------------------------------------
    public void logInfo(Channel channel, String message, String callbackId) {
        Main.info("target " + channel.getName() + ": " + message);
    }

    //---------------------------------------------------------------
    public void logWarning(Channel channel, String message, String callbackId) {
        Main.warn("target " + channel.getName() + ": " + message);
    }

    //---------------------------------------------------------------
    public void logError(Channel channel, String message, String callbackId) {
        Main.error("target " + channel.getName() + ": " + message);
    }

    //---------------------------------------------------------------
    private String getCallbackConnectorId(String callbackId) {
        int index = callbackId.indexOf("::");
        return callbackId.substring(0, index);
    }
    
}
