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

import org.apache.wink.json4j.JSONArray;
import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

//-------------------------------------------------------------------
public class Client extends Connector {

    private Target connectedTarget;

    //---------------------------------------------------------------
    public Client(Channel channel) {
        super(channel);
        _register();
    }

    //---------------------------------------------------------------
    public boolean isClient() {
        return true;
    }

    //---------------------------------------------------------------
    public Target getConnectedTarget() {
        return connectedTarget;
    }

    //---------------------------------------------------------------
    protected void _connect(Target target) {
        if (null == target) return;

        Lock.lock();

        try {
            connectedTarget = target;
        }
        finally {
            Lock.unlock();
        }
    }

    //---------------------------------------------------------------
    protected void _disconnect(Target target) {
        if (null == target) return;

        Lock.lock();

        try {
            connectedTarget = null;
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
          result.put("connectedTargetIds", new JSONArray());
      }
      catch (JSONException e) {
          throw new RuntimeException(e);
      }

      return result;
    }

}
