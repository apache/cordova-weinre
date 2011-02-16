/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server.http;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.handler.RequestLogHandler;

//-------------------------------------------------------------------
public class FilteredRequestLogHandler extends RequestLogHandler {

    //---------------------------------------------------------------
    @Override
    public void handle(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        int status = baseRequest.getResponse().getStatus();
        
        if (status == 200) return;
        if (status == 304) return;

        super.handle(target, baseRequest, request, response);
    }

}
