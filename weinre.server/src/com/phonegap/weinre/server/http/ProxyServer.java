/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server.http;

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

import com.phonegap.weinre.server.Main;
import com.phonegap.weinre.server.ServerSettings;

public class ProxyServer {
    private ServerSettings settings;
    
    public ProxyServer(ServerSettings settings) {
        super();
        
        this.settings = settings;
    }
    
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
