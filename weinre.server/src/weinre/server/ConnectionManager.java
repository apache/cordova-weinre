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
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//-------------------------------------------------------------------
public class ConnectionManager {

    static final public ConnectionManager $ = new ConnectionManager();

    private Map<String,Client> clientMap;
    private Map<String,Target> targetMap;
    private boolean            listening = false;

    //---------------------------------------------------------------
    private ConnectionManager() {
        super();

        clientMap = Collections.synchronizedMap(new HashMap<String,Client>());
        targetMap = Collections.synchronizedMap(new HashMap<String,Target>());
    }

    //---------------------------------------------------------------
    public void startChannelListener() {
        if (listening) return;
        listening = true;

        ChannelManager.$.addEventListener(new ChannelManagerEventListener() {

            @Override
            public void channelRegistered(Channel channel) {
            }

            @Override
            public void channelDeregistered(Channel channel) {
                Connector connector = channel.getConnector();
                if (null == connector) return;

                if (connector.isClient()) ConnectionManager.$._closeClient((Client) connector);
                if (connector.isTarget()) ConnectionManager.$._closeTarget((Target) connector);
            }
        });
    }

    //---------------------------------------------------------------
    public void addClient(Client client) {
        clientMap.put(client.getName(), client);
        _sendAllClientsEvent("WeinreClientEvents", client.getId(), "clientRegistered", client.getDescription());
    }

    //---------------------------------------------------------------
    public void addTarget(Target target) {
        targetMap.put(target.getName(), target);
        _sendAllClientsEvent("WeinreClientEvents", target.getId(), "targetRegistered", target.getDescription());
    }

    //---------------------------------------------------------------
    private void _removeClient(Client client) {
        _sendAllClientsEvent("WeinreClientEvents", client.getId(), "clientUnregistered", client.getName());
        clientMap.remove(client.getName());
    }

    //---------------------------------------------------------------
    private void _removeTarget(Target target) {
        _sendAllClientsEvent("WeinreClientEvents", target.getId(), "targetUnregistered", target.getName());
        targetMap.remove(target.getName());
    }

    //---------------------------------------------------------------
    public Client getClient(String name) {
        return clientMap.get(name);
    }

    //---------------------------------------------------------------
    public Target getTarget(String name) {
        return targetMap.get(name);
    }

    //---------------------------------------------------------------
    public List<Client> getClients(String id) {
        List<Client> result = new ArrayList<Client>();

        for (Client client: clientMap.values()) {
            if (client.getId().equals(id)) {
                result.add(client);
            }
        }

        return result;
    }

    //---------------------------------------------------------------
    public List<Target> getTargets(String id) {
        List<Target> result = new ArrayList<Target>();

        for (Target target: targetMap.values()) {
            if (target.getId().equals(id)) {
                result.add(target);
            }
        }

        return result;
    }

    //---------------------------------------------------------------
    public void connect(Client client, Target target) {
        if ((client == null) || (target == null)) return;

        Target connectedTarget = client.getConnectedTarget();
        if (connectedTarget == target) return;

        disconnect(client, connectedTarget);

        client._connect(target);
        target._connect(client);

        _sendConnectionCreatedEvent(client, target);
    }

    //---------------------------------------------------------------
    public void disconnect(Client client, Target target) {
        if ((client == null) || (target == null)) return;

        client._disconnect(target);
        target._disconnect(client);

        _sendConnectionDestroyedEvent(client, target);
    }

    //---------------------------------------------------------------
    private void _sendConnectionCreatedEvent(Client client, Target target) {
        _sendConnectionEvent(client, target, "connectionCreated");
    }

    //---------------------------------------------------------------
    private void _sendConnectionDestroyedEvent(Client client, Target target) {
        _sendConnectionEvent(client, target, "connectionDestroyed");
    }

    //---------------------------------------------------------------
    private void _sendConnectionEvent(Client client, Target target, String message) {
        String clientName = client.getChannel().getName();
        String targetName = target.getChannel().getName();

        _sendAllClientsEvent("WeinreClientEvents", client.getId(), message, clientName, targetName);
        target.getChannel().sendEvent("WeinreTargetEvents", message, clientName, targetName);
    }

    //---------------------------------------------------------------
    private void _sendAllClientsEvent(String intfName, String id, String message, Object... args) {
        for (Client aClient: getClients(id)) {
            aClient.getChannel().sendEvent(intfName, message, args);
        }
    }

    //---------------------------------------------------------------
    protected void closeConnector(Connector connector) {
        if (null == connector) return;

        if (connector.isClient()) _closeClient((Client)connector);
        if (connector.isTarget()) _closeTarget((Target)connector);
    }

    //---------------------------------------------------------------
    private void _closeClient(Client client) {
        if (null == client) return;

        Target target = client.getConnectedTarget();
        if (null != target) {
            disconnect(client, target);
        }

        _removeClient(client);
    }

    //---------------------------------------------------------------
    private void _closeTarget(Target target) {
        if (null == target) return;

        List<Client> clients = target.getConnectedClients();

        for (Client client: clients) {
            disconnect(client, target);
        }

        _removeTarget(target);
    }

}
