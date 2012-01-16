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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//-------------------------------------------------------------------
public class ChannelManager {

    static final public ChannelManager $ = new ChannelManager();

    private Map<String, Channel>              channelMap;
    private List<ChannelManagerEventListener> eventListeners;

    //---------------------------------------------------------------
    private ChannelManager() {
        super();

        channelMap     = new HashMap<String, Channel>();
        eventListeners = new ArrayList<ChannelManagerEventListener>();
    }

    //---------------------------------------------------------------
    public void addEventListener(ChannelManagerEventListener listener) {
        eventListeners.add(listener);
    }

    //---------------------------------------------------------------
    public void removeEventListener(ChannelManagerEventListener listener) {
        eventListeners.add(listener);
    }

    //---------------------------------------------------------------
    private void fireRegisteredEvent(Channel channel) {
        for (ChannelManagerEventListener listener: eventListeners) {
            listener.channelRegistered(channel);
        }
    }

    //---------------------------------------------------------------
    private void fireDeregisteredEvent(Channel channel) {
        for (ChannelManagerEventListener listener: eventListeners) {
            listener.channelDeregistered(channel);
        }
    }

    //---------------------------------------------------------------
    public Channel getChannel(String channelName) {
        return channelMap.get(channelName);
    }

    //---------------------------------------------------------------
    public Channel getChannel(String channelName, String remoteAddress) {
        Channel channel = getChannel(channelName);
        if (null == channel) return null;

        if (!channel.getRemoteAddress().equals(remoteAddress)) return null;

        return channel;
    }

    //---------------------------------------------------------------
    public List<Channel> getChannels() {
        return new ArrayList<Channel>(channelMap.values());
    }

    //---------------------------------------------------------------
    public Channel registerChannel(String pathPrefix, String channelName, String id, String remoteHost, String remoteAddress) {
        if (channelMap.containsKey(channelName)) return null;

        Channel channel = new Channel(pathPrefix, channelName, id, remoteHost, remoteAddress);
        channelMap.put(channelName, channel);

        fireRegisteredEvent(channel);

        return channel;
    }

    //---------------------------------------------------------------
    public Channel deregisterChannel(String channelName) {
        Channel channel = getChannel(channelName);
        if (null == channel) return null;

        fireDeregisteredEvent(channel);

        channelMap.remove(channelName);

        return channel;
    }

}

