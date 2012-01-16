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
import org.eclipse.jetty.server.handler.HandlerCollection;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.handler.RequestLogHandler;
import org.eclipse.jetty.server.nio.SelectChannelConnector;
import org.eclipse.jetty.util.component.LifeCycle;

import weinre.server.Main;
import weinre.server.ServerSettings;

//-------------------------------------------------------------------
public class HttpServer {

    private Main           main;
    private ServerSettings settings;

    //---------------------------------------------------------------
    public HttpServer(Main main, ServerSettings settings) {
        super();

        this.main     = main;
        this.settings = settings;
    }

    //---------------------------------------------------------------
    public Server run() throws Exception {
        String hostName     = settings.getBoundHostValue();
        String niceHostName = settings.getNiceHostName();

        SelectChannelConnector connector = new SelectChannelConnector();

        connector.setHost(hostName);
        connector.setPort(settings.getHttpPort());
        connector.setReuseAddress(settings.reuseAddr());
        connector.setResolveNames(true);

        Server server = new Server();
        server.setConnectors(new Connector[] { connector });
        server.addLifeCycleListener(new LifeCycle.Listener() {
            public void lifeCycleStarting(LifeCycle event) {}
            public void lifeCycleStarted(LifeCycle event) { main.serverStarted(); }
            public void lifeCycleFailure(LifeCycle event, Throwable cause) {}
            public void lifeCycleStopping(LifeCycle event) {}
            public void lifeCycleStopped(LifeCycle event) {}
        });

        // set up the main handlers
        HandlerList handlers = new HandlerList();

        // debug handler
//        DebugHandler debugHandler = new DebugHandler();
//        handlers.addHandler(debugHandler);

        HttpSocketHandler httpSocketHandler;

        // client socket handler
        httpSocketHandler = new HttpSocketHandler("/ws/client");
        handlers.addHandler(httpSocketHandler);

        // target socket handler
        httpSocketHandler = new HttpSocketHandler("/ws/target");
        handlers.addHandler(httpSocketHandler);

//        runChannelTester();

        // handler for /web (static files in jar)
        ClassPathResourceHandler handlerStaticFiles = new ClassPathResourceHandler("web");
        handlers.addHandler(handlerStaticFiles);

        // outer collection of handlers for management
        HandlerCollection handlerOuter = new HandlerCollection();

        // add the main handlers
        handlerOuter.addHandler(handlers);

        // add a request logger
        RequestLogHandler requestLogHandler = new FilteredRequestLogHandler();

        NCSARequestLog requestLog = new NCSARequestLog();
        requestLog.setRetainDays(90);
        requestLog.setAppend(true);
        requestLog.setExtended(false);
        requestLog.setLogTimeZone("GMT");
        requestLogHandler.setRequestLog(requestLog);

        handlerOuter.addHandler(requestLogHandler);

        // serve with the outer handler
        server.setHandler(handlerOuter);

        // start the JS thread
//        JavaScriptRunner.runThreaded("server/main.js", null, null);

        // start the server
        try {
            server.start();
        }
        catch (IOException e) {
            throw e;
        }

        Main.info("HTTP server started at http://" + niceHostName + ":" + settings.getHttpPort());

        return server;
    }

}
