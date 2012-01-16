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
import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.util.resource.Resource;

import weinre.server.ExtensionManager;

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

        // handle extensions
        if (path.startsWith("/client/extensions/")) {
            return ExtensionManager.getResource(path);
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
