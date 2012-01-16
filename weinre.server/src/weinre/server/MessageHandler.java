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

import java.io.PrintWriter;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import org.apache.wink.json4j.JSONArray;
import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

//-------------------------------------------------------------------
public class MessageHandler {
    private PrintWriter messageLog;

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
    private MessageHandler() {
        messageLog = Main.getSettings().getMessageLog();
    }

    //---------------------------------------------------------------
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
                        accRequest.put("_from", channel.getName() + "#" + channel.getId());

                        if (null != messageLog) {
                            messageLog.print(accRequest.toString(true));
                            messageLog.println(",");
                        }

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

    //---------------------------------------------------------------
    @SuppressWarnings({ "rawtypes", "unchecked" })
    private void serviceMethodInvoker(Channel channel, String intfName, String methodName, JSONArray argsJSON) {
        Object service;

        String methodSignature = intfName + "." + methodName + "()";

        if (Main.isDebug()) {
            String methodSignatureParms = intfName + "." + methodName + "(" + argsJSON.toString() + ")";
            Main.debug(channel.getName() + ": recv " + methodSignatureParms);
        }

        try {
            service = channel.getService(intfName);
        }
        catch (RuntimeException e) {
            Main.warn("unable to get service object for: " + methodSignature + "; " + e);
            return;
        }

        if (null == service) {
            redirectToConnections(channel, intfName, methodName, argsJSON);
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

        Main.warn("no method found to invoke for: " + methodSignature);
    }

    //---------------------------------------------------------------
    private void redirectToConnections(Channel channel, String interfaceName, String methodName, JSONArray args) {
        Connector connector = channel.getConnector();
        if (null == connector) return;

        List<Connector> connections = connector.getConnections();

        for (Connector connection: connections) {
            connection.getChannel().sendEvent(interfaceName, methodName, args.toArray());
        }
    }


}
