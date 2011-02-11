/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2011 IBM Corporation
 */

package com.phonegap.weinre.server.service;

import java.io.IOException;

import com.phonegap.weinre.server.Channel;
import com.phonegap.weinre.server.Main;

public class Network {

    public Network() {
        super();
    }
    
    public void cachedResources(Channel channel, String callbackId) throws IOException {
        Main.warn(getClass().getName() + ".cachedResources() not implemented");

//      channel.sendCallback("WiNetwork", callbackId, /*Object resources*/ (Object) null);
    }


    public void resourceContent(Channel channel, Long frameId, String url, Boolean base64Encode, String callbackId) throws IOException {
        Main.warn(getClass().getName() + ".resourceContent() not implemented");

//      channel.sendCallback("WiNetwork", callbackId, /*String content*/ (Object) null);
    }

}
