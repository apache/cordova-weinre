/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.wink.json4j.JSONObject;

/**
 * 
 */
abstract public class Connector {

    static final protected Lock Lock = new ReentrantLock();
    
    private Channel channel;
    
    /**
     * 
     */
    public Connector(Channel channel) {
        super();
        
        this.channel = channel;
        channel._setConnector(this);
    }
    
    /**
     * 
     */
    protected void _register() {
        if (isClient()) ConnectionManager.$.addClient((Client) this);
        if (isTarget()) ConnectionManager.$.addTarget((Target) this);
    }
    
    /**
     * 
     */
    public Channel getChannel() {
        return channel;
    }
    
    /**
     * 
     */
    public String getName() {
        return channel.getName();
    }
    
    /**
     * 
     */
    public List<Connector> getConnections() {
        List<Connector> result = new ArrayList<Connector>();
        
        if (isClient()) {
            Connector target = ((Client) this).getConnectedTarget();
            if (null != target) {
                result.add(target);
            }
        }
        
        else if (isTarget()) {
            result.addAll(((Target) this).getConnectedClients());
        }
        
        else {
            throw new RuntimeException("connector which isn't a client or target");
        }
        
        return result;
    }
    
    /**
     * 
     */
    abstract public JSONObject getDescription();
    
    /**
     * 
     */
    public boolean isClosed() {
        return channel.isClosed();
    }
    
    /**
     * 
     */
    public boolean isClient() {
        return false;
    }
    
    /**
     * 
     */
    public boolean isTarget() {
        return false;
    }
    
    /**
     * 
     */
    public String toString() {
        return getClass().getName() + "{" + channel + "}";
    }
}
