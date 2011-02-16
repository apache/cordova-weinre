/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 */
public class ChannelManager {

    static final public ChannelManager $ = new ChannelManager();

    private Map<String, Channel>              channelMap;
    private List<ChannelManagerEventListener> eventListeners;
    
    /**
     * 
     */
    private ChannelManager() {
        super();
        
        channelMap     = new HashMap<String, Channel>();
        eventListeners = new ArrayList<ChannelManagerEventListener>();
    }

    /**
     * 
     */
    public void addEventListener(ChannelManagerEventListener listener) {
        eventListeners.add(listener);
    }
    
    /**
     * 
     */
    public void removeEventListener(ChannelManagerEventListener listener) {
        eventListeners.add(listener);
    }

    /**
     * 
     */
    private void fireRegisteredEvent(Channel channel) {
        for (ChannelManagerEventListener listener: eventListeners) {
            listener.channelRegistered(channel);
        }
    }
    
    /**
     * 
     */
    private void fireDeregisteredEvent(Channel channel) {
        for (ChannelManagerEventListener listener: eventListeners) {
            listener.channelDeregistered(channel);
        }
    }

    /**
     * 
     */
    public Channel getChannel(String channelName) {
        return channelMap.get(channelName);
    }
    
    /**
     * This version of getChannel() double-checks that the remoteAddress
     * this request came from matches the original remoteAddress the
     * channel was created with.
     */
    public Channel getChannel(String channelName, String remoteAddress) {
        Channel channel = getChannel(channelName);
        if (null == channel) return null;
        
        if (!channel.getRemoteAddress().equals(remoteAddress)) return null;
        
        return channel;
    }
    
    /**
     * 
     */
    public List<Channel> getChannels() {
        return new ArrayList<Channel>(channelMap.values());
    }
    
    /**
     * 
     */
    public Channel registerChannel(String pathPrefix, String channelName, String remoteHost, String remoteAddress) {
        if (channelMap.containsKey(channelName)) return null;
        
        Channel channel = new Channel(pathPrefix, channelName, remoteHost, remoteAddress);
        channelMap.put(channelName, channel);
        
        fireRegisteredEvent(channel);
        
        return channel;
    }
    
    /**
     * 
     */
    public Channel deregisterChannel(String channelName) {
        Channel channel = getChannel(channelName);
        if (null == channel) return null;
        
        fireDeregisteredEvent(channel);
        
        channelMap.remove(channelName);
        
        return channel;
    }

}

