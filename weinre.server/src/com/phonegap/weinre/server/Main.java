/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package com.phonegap.weinre.server;

import java.io.PrintStream;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.util.log.Log;
import org.eclipse.jetty.util.log.Logger;
import org.eclipse.jetty.util.log.StdErrLog;

import com.phonegap.weinre.server.http.HttpServer;


/**
 * 
 */
public class Main {
    
    private static ServerSettings  Settings;
    private static Logger          Logger;
    
    public  Server       server;
    private PrintStream  consoleStdout;
    private PrintStream  consoleStderr;

    /**
     * 
     */
    static public void main(String[] args) throws Throwable {
        Main main = new Main(args);
        
        main.run();
    }

    /**
     * 
     */
    static public ServerSettings getSettings() {
        return Settings;
    }

    /**
     * 
     */
    static public void warn(  String message ) { Logger.warn(message);  }
    static public void info(  String message ) { Logger.info(message);  }
    static public void debug( String message ) { Logger.debug(message); }

    /**
     * 
     */
    public Main(String[] args) {
        super();
        
        Settings = ServerSettings.getOptions(args);
        
        consoleStdout = ConsoleOutputStream.newPrintStream(this, System.out, true);
        consoleStderr = ConsoleOutputStream.newPrintStream(this, System.err, false);

        System.setOut(consoleStdout);
        System.setErr(consoleStderr);
    }
    
    /**
     * 
     */
    public void run() throws Throwable, Exception {
        httpServerStart();
        httpServerWaitTillDone();
        exit();
    }
    
    /**
     * 
     */
    public int exit() {
        if (null != server) {
            try {
                server.setGracefulShutdown(1000);
                server.setStopAtShutdown(true);

                for (org.eclipse.jetty.server.Connector connector: server.getConnectors()) {
                    connector.stop();
                    connector.close();
                }
                server.stop();
            }
            catch (Exception e) {
                warn("exception stopping the server: " + e);
                e.printStackTrace();
            }
        } 
        
        System.exit(0);
        return 0;
    }

    /**
     * 
     */
    public void httpServerStart() {
        // get the default logger - this should be the first thing to touch the log
        Logger defaultLog = Log.getLog();
        
        if (defaultLog instanceof StdErrLog) {
            ((StdErrLog) defaultLog).setHideStacks(true);
        }

        // create a special logger for weinre messages
        Logger = org.eclipse.jetty.util.log.Log.getLogger("weinre");
        Logger.setDebugEnabled(Settings.getVerbose());
        
        server = null;
        try {
            server = new HttpServer(this, Settings).run();
        }
        catch (Throwable e) {
            severeError("exception launching server: " + e);
        }
        
        ConnectionManager.$.startChannelListener();
        WatchDog.start();
        MessageHandler.start();
    }

    /**
     * 
     */
    public void httpServerWaitTillDone() {
        try {
            server.join();
        }
        catch (Throwable e) {
            severeError("exception waiting for server to stop: " + e);
        }
    }
    
    /**
     * 
     */
    public void serverStarted() {
    }
    
    /**
     * 
     */
    public void addServerConsoleMessage(String line, boolean stdout) {
    }
    
    /**
     * 
     */
    public int severeError(String message) {
        Logger.warn(message);
        Logger.warn("exiting...");
        return exit();
    }
    
}
