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

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
    private void dump(PrintStream oStream, String target, Request request, Response response) {
        oStream.println("----------------------------------------------------------");
        oStream.println("target: " + target);

        oStream.println("request:");
        oStream.println("   headers:");
        dumpHeaders(oStream, request);

        oStream.println("response:");
        oStream.println("   status: " + response.getStatus());
    }

    //---------------------------------------------------------------
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
