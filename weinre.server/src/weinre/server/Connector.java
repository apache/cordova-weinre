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
import java.util.List;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.wink.json4j.JSONObject;

//-------------------------------------------------------------------
abstract public class Connector {

    static final protected Lock Lock = new ReentrantLock();

    private Channel channel;

    //---------------------------------------------------------------
    public Connector(Channel channel) {
        super();

        this.channel = channel;
        channel._setConnector(this);
    }

    //---------------------------------------------------------------
    protected void _register() {
        if (isClient()) ConnectionManager.$.addClient((Client) this);
        if (isTarget()) ConnectionManager.$.addTarget((Target) this);
    }

    //---------------------------------------------------------------
    public Channel getChannel() {
        return channel;
    }

    //---------------------------------------------------------------
    public String getName() {
        return channel.getName();
    }

    //---------------------------------------------------------------
    public String getId() {
        return channel.getId();
    }

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
    abstract public JSONObject getDescription();

    //---------------------------------------------------------------
    public boolean isClosed() {
        return channel.isClosed();
    }

    //---------------------------------------------------------------
    public boolean isClient() {
        return false;
    }

    //---------------------------------------------------------------
    public boolean isTarget() {
        return false;
    }

    //---------------------------------------------------------------
    public String toString() {
        return getClass().getName() + "{" + channel + "}";
    }
}
