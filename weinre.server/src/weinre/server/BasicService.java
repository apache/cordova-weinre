/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server;

import java.io.IOException;
import java.util.List;

import org.apache.wink.json4j.JSONArray;

//-------------------------------------------------------------------
public abstract class BasicService {

    public static String lastActivePanelName;
    
    //---------------------------------------------------------------
    public BasicService() {
        super();
    }

    //---------------------------------------------------------------
    public String getInterfaceName() {
        return getClass().getSimpleName();
    }
    
    //---------------------------------------------------------------
    public void __doesNotUnderstand(Channel channel, String methodName, JSONArray args) throws IOException {
        Connector connector = channel.getConnector();
        if (null == connector) return;
        
        List<Connector> connections = connector.getConnections();
        
        for (Connector connection: connections) {
            connection.getChannel().sendEvent(getInterfaceName(), methodName, args.toArray());
        } 
    }

}
