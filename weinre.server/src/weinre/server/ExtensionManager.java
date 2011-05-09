/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2011 IBM Corporation
 */

package weinre.server;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.jetty.util.resource.Resource;

//-------------------------------------------------------------------
public class ExtensionManager {
    static private File     weinreHomeDir = null;     
    static private File     weinreExtDir  = null;    
    static private long     weinreExtDate = 0L;
    static private String[] extensions    = null;
    
    static private String[] EMPTY_STRING_ARRAY = {};

    //---------------------------------------------------------------
    static {
        initExtensions();
    }
    
    //---------------------------------------------------------------
    static public String[] getExtensions() {
        if (null == weinreExtDir) return extensions;
        
        if (weinreExtDate != weinreExtDir.lastModified()) {
            initExtensions();
        }
        
        return extensions;
    }
    
    //---------------------------------------------------------------
    // path: /client/extensions/weinre-ext-sample/extension.html
    static public Resource getResource(String path) throws MalformedURLException {
        if (null == weinreExtDir) return null;
        
        File resourceFile = new File(weinreExtDir, path.substring(18));
        if (!resourceFile.exists()) return null;
        
        try {
            return Resource.newResource(resourceFile.toURI().toURL().toExternalForm(), false);
        } 
        catch (IOException e) {
            throw new MalformedURLException();
        }
    }
    
    //---------------------------------------------------------------
    static private void initExtensions() {
        
        extensions = EMPTY_STRING_ARRAY;
            
        weinreHomeDir = new File(System.getProperty("user.home"), ".weinre");
        if (!weinreHomeDir.isDirectory()) {
            Main.info("extensions not enabled: ~/.weinre is not a directory");
            return;
        }

        weinreExtDir  = new File(weinreHomeDir, "extensions");
        weinreExtDate = weinreExtDir.lastModified();
        if (!weinreExtDir.isDirectory()) {
            Main.info("extensions not enabled: ~/.weinre/extensions is not a directory");
            return;
        }
        
        List<String> extensionList = new ArrayList<String>();
        
        String[] entries = weinreExtDir.list();
        for (String entry: entries) {
            if (entry.startsWith(".")) continue;
            
            File extDir = new File(weinreExtDir, entry);
            if (!extDir.isDirectory()) continue;
            
            File extensionHtml = new File(extDir, "extension.html");
            if (!extensionHtml.isFile()) continue;
            
            extensionList.add(entry);
        }
        
        extensions = extensionList.toArray(EMPTY_STRING_ARRAY);
    }
    
}
