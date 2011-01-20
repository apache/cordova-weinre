/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package com.phonegap.weinre.server.http;

import java.io.IOException;
import java.io.PrintStream;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.Response;
import org.eclipse.jetty.server.handler.HandlerWrapper;


/** 
* Debug Handler.
* A lightweight debug handler that can be used in production code.
* Details of the request and response are written to an output stream
* and the current thread name is updated with information that will link
* to the details in that output.
*/
public class DebugHandler extends HandlerWrapper {

    /**
     * 
     */
    public void handle(String target, Request request, HttpServletRequest servletRequest, HttpServletResponse servletResponse) throws IOException, ServletException {
        try {
            getHandler().handle(target, request, servletRequest, servletResponse);
        }
        catch(IOException e) {
          throw new RuntimeException(e);
        }
    
        Response response = request.getResponse();
        
        dump(System.out, target, request, response);
    }

    /**
     * 
     */
    private void dump(PrintStream oStream, String target, Request request, Response response) {
        oStream.println("----------------------------------------------------------");
        oStream.println("target: " + target);
        
        oStream.println("request:");
        oStream.println("   headers:");
        dumpHeaders(oStream, request);
        
        oStream.println("response:");
        oStream.println("   status: " + response.getStatus());
    }
    
    /**
     * 
     */
    @SuppressWarnings("rawtypes")
    private void dumpHeaders(PrintStream oStream, Request request) {
        Enumeration e = request.getHeaderNames();
        while (e.hasMoreElements()) {
            String name = (String) e.nextElement();
            Enumeration e2 = request.getHeaders(name);
            while (e2.hasMoreElements()) {
                String value = (String) e2.nextElement();
                oStream.println("      " + name + ": " + value);
            }
        }
    }

}
