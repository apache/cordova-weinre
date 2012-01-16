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
import java.util.LinkedList;
import java.util.List;

import org.apache.wink.json4j.JSONArray;
import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

//-------------------------------------------------------------------
public class Target extends Connector {

    private List<Client> connectedClients;
    private String       url;

    //---------------------------------------------------------------
    public Target(Channel channel, String url) {
        super(channel);

        connectedClients = new ArrayList<Client>();
        this.url = url;
        _register();

    }

    //---------------------------------------------------------------
    public String getURL() {
        return this.url;
    }

    //---------------------------------------------------------------
    public boolean isTarget() {
        return true;
    }

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
    public JSONObject getDescription() {
        JSONObject result = new JSONObject();

        try {
            result.put("channel",            getChannel().getName());
            result.put("id",                 getChannel().getId());
            result.put("hostName",           getChannel().getRemoteHost());
            result.put("url",                this.url);
            result.put("connectedClientIds", new JSONArray());
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        return result;
    }

}
