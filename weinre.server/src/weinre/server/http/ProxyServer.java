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

package weinre.server.http;

import java.io.IOException;

import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.NCSARequestLog;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.handler.RequestLogHandler;
import org.eclipse.jetty.server.nio.SelectChannelConnector;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.servlets.ProxyServlet;

import weinre.server.Main;
import weinre.server.ServerSettings;

//-------------------------------------------------------------------
public class ProxyServer {
    private ServerSettings settings;

    //---------------------------------------------------------------
    public ProxyServer(ServerSettings settings) {
        super();

        this.settings = settings;
    }

    //---------------------------------------------------------------
    public void run() throws Exception {
        SelectChannelConnector connector = new SelectChannelConnector();

        connector = new SelectChannelConnector();

        String hostName = settings.getBoundHost();

        connector.setHost(hostName);
        connector.setPort(settings.getHttpPort()+1);
        connector.setReuseAddress(false);

        Server proxyServer = new Server();
        proxyServer.setConnectors(new Connector[] { connector });

        HandlerList handlers = new HandlerList();

        handlers = new HandlerList();

        RequestLogHandler requestLogHandler = new RequestLogHandler();

        requestLogHandler = new RequestLogHandler();

        NCSARequestLog requestLog;

        requestLog = new NCSARequestLog();
        requestLog.setRetainDays(90);
        requestLog.setAppend(true);
        requestLog.setExtended(false);
        requestLog.setLogTimeZone("GMT");
        requestLogHandler.setRequestLog(requestLog);

        handlers.addHandler(requestLogHandler);

        ServletContextHandler handlerProxy = new ServletContextHandler();
        handlerProxy.setContextPath("/");
        ProxyServlet proxyServlet = new ProxyServlet();
        handlerProxy.addServlet(new ServletHolder(proxyServlet), "/");
        handlers.addHandler(handlerProxy);

        proxyServer.setHandler(handlers);

        try {
            proxyServer.start();
        }
        catch (IOException e) {
            Main.warn("unable to start proxy server: " + e.getMessage());
            proxyServer.stop();
        }

        Main.info("HTTP proxy server started at http://" + settings.getNiceHostName() + ":" + (settings.getHttpPort()+1));
    }
}
