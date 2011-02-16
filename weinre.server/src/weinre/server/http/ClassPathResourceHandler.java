/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server.http;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.util.resource.Resource;

//-------------------------------------------------------------------
public class ClassPathResourceHandler extends ResourceHandler {

    private String pathPrefix;

    //---------------------------------------------------------------
    public ClassPathResourceHandler(String pathPrefix) {
        super();
        
        this.pathPrefix = pathPrefix;
    }

    //---------------------------------------------------------------
    public Resource getResource(String path) throws MalformedURLException {
        if ((path == null) || !path.startsWith("/")) {
            throw new MalformedURLException(path);
        }

        path = pathPrefix + path;
        URL url = getClass().getClassLoader().getResource(path);
        if (url != null)
            try {
                return Resource.newResource(url);
            } 
            catch (IOException e) {
                throw new MalformedURLException();
            }
        
        return null;
    }

}
