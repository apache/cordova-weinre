/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package com.phonegap.weinre.server.http;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.wink.json4j.JSONArray;
import org.apache.wink.json4j.JSONException;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.handler.AbstractHandler;

import com.phonegap.weinre.server.Channel;
import com.phonegap.weinre.server.ChannelManager;
import com.phonegap.weinre.server.Main;
import com.phonegap.weinre.server.Utility;

/**
 * 
 */
public class HttpSocketHandler extends AbstractHandler {
    private String pathPrefix; 
    private int    pathPrefixParts;
    
    /**
     * 
     */
    public HttpSocketHandler(String pathPrefix) {
        super();
        
        this.pathPrefix      = pathPrefix;
        this.pathPrefixParts = pathPrefix.split("/").length;
    }
    
    /**
     * 
     */
    @Override
    public void handle(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // ! * pathPrefix*
        if (!target.startsWith(pathPrefix)) return;
        
        String method = baseRequest.getMethod();
        
        setCORSHeaders(response);
        setCacheHeaders(response);
        
        // OPTIONS pathPrefix
        if (target.equals(pathPrefix) && method.equals("OPTIONS")) {
            baseRequest.setHandled(true);
            handleOptions(target, baseRequest, request, response);
            return;
        }

        // POST pathPrefix
        if (target.equals(pathPrefix) && method.equals("POST")) {
            baseRequest.setHandled(true);
            handleCreate(target, baseRequest, request, response);
            return;
        }

        // * pathPrefix
        if (target.equals(pathPrefix)) {
            baseRequest.setHandled(true);
            response.sendError(405);
            return;
        }
        
        // * pathPrefix/x/*
        String[] parts = target.split("/");
        if (parts.length != pathPrefixParts + 1) {
            baseRequest.setHandled(true);
            response.sendError(404);
        }
        
        // 
        if (parts.length <= pathPrefixParts) {
            baseRequest.setHandled(true);
            response.sendError(405);
        }
        
        String channel = parts[pathPrefixParts];
        
        // OPTIONS pathPrefix/x
        if (method.equals("OPTIONS")) {
            baseRequest.setHandled(true);
            handleOptions(target, baseRequest, request, response);
            return;
        }
        
        // GET pathPrefix/x
        if (method.equals("GET")) {
            baseRequest.setHandled(true);
            handleGet(channel, target, baseRequest, request, response);
            return;
        }
        
        // POST pathPrefix/x
        if (method.equals("POST")) {
            baseRequest.setHandled(true);
            handlePost(channel, target, baseRequest, request, response);
            return;
        }
        
        // * pathPrefix/x
        baseRequest.setHandled(true);
        response.sendError(405);
    }

    /**
     * 
     */
    private void setCORSHeaders(HttpServletResponse response) {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Max-Age", "600");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST");
    }
    
    /**
     * 
     */
    private void setCacheHeaders(HttpServletResponse response) {
        response.setHeader("Pragma",        "no-cache");
        response.setHeader("Expires",       "0");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Cache-Control", "no-store");
    }
    
    /**
     * 
     */
    public void handleOptions(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        response.setStatus(200);
        response.setContentType("text/plain");
    }

    /**
     * 
     */
    public void handleCreate(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String channelName = "" + Utility.getNextSequenceNumber();
        
        ChannelManager.$.registerChannel(pathPrefix, channelName, request.getRemoteHost(), request.getRemoteAddr());
        
        response.setStatus(200);
        response.setContentType("application/json");
        
        ServletOutputStream oStream = response.getOutputStream();
        oStream.print("{\"channel\": " + channelName + "}");
        oStream.close();
    }

    /**
     * 
     */
    public void handleGet(String channelName, String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Channel channel = ChannelManager.$.getChannel(channelName, request.getRemoteAddr());
        if (null == channel) {
            response.setStatus(404);
            return;
        }

        channel.updateLastRead();
        
        List<String> json; 
        try {
            json = channel.getResponses(Main.getSettings().getReadTimeoutSeconds());
        } 
        catch (InterruptedException e) {
            throw new IOException(e);
        }
        
        response.setStatus(200);
        response.setContentType("application/json");

        ServletOutputStream oStream = response.getOutputStream();
        printJSONList(oStream, json);

        oStream.close();
    }

    /**
     * 
     */
    private void printJSONList(ServletOutputStream oStream, List<String> json) throws IOException {
        try {
            oStream.print(new JSONArray(json).toString());
        } 
        catch (JSONException e) {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * 
     */
    public void handlePost(String channelName, String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Channel channel = ChannelManager.$.getChannel(channelName, request.getRemoteAddr());
        if (null == channel) {
            response.setStatus(404);
            return;
        }

//        if (!"text/plain".equals(baseRequest.getContentType())) {
//            response.setStatus(415);
//            return;
//        }

        if (0 == baseRequest.getContentLength()) {
            response.setStatus(400);
            return;
        }
        
        try {
            String json = readRequestBody(request.getInputStream());
            channel.postRequest(json);
        }
        catch (IOException e) {
            response.setStatus(400);
            return;
        }
        
        response.setStatus(200);
        response.setContentType("text/plain");
        response.getOutputStream().close();
    }
    
    /**
     * 
     */
    private String readRequestBody(InputStream is) throws IOException {
        StringBuffer stringBuffer = new StringBuffer();
        Reader       reader       = new InputStreamReader(is, "UTF-8");
        char[]       buffer       = new char[4096];
        
        int read;
        while ((read = reader.read(buffer)) > 0) {
            stringBuffer.append(buffer, 0, read);
        }
        
        return stringBuffer.toString();
    }
}
