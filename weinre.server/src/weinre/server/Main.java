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

package weinre.server;

import java.io.PrintStream;
import java.io.PrintWriter;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.util.log.Log;
import org.eclipse.jetty.util.log.Logger;
import org.eclipse.jetty.util.log.StdErrLog;

import weinre.server.http.HttpServer;

//-------------------------------------------------------------------
public class Main {

    private static ServerSettings  Settings;
    private static Logger          Logger;

    public  Server       server;
    private PrintStream  consoleStdout;
    private PrintStream  consoleStderr;

    //---------------------------------------------------------------
    static public void main(String[] args) throws Throwable {
        Main main = new Main(args);

        main.run();
    }

    //---------------------------------------------------------------
    static public ServerSettings getSettings() {
        return Settings;
    }

    //---------------------------------------------------------------
    static public boolean isDebug() {
        return Settings.getVerbose();
    }

    //---------------------------------------------------------------
    static public void warn(  String message ) { Logger.warn(message);  }
    static public void info(  String message ) { Logger.info(message);  }
    static public void debug( String message ) { Logger.debug(message); }
    static public void error( String message ) { Logger.warn(message);  }

    //---------------------------------------------------------------
    public Main(String[] args) {
        super();

        Settings = ServerSettings.getOptions(args);
        if (null == Settings) System.exit(0);

        if (null != Settings.getMessageLog()) {
            Settings.getMessageLog().println("[");
        }

        Runtime.getRuntime().addShutdownHook(onShutdownThread());

        consoleStdout = ConsoleOutputStream.newPrintStream(this, System.out, true);
        consoleStderr = ConsoleOutputStream.newPrintStream(this, System.err, false);

        System.setOut(consoleStdout);
        System.setErr(consoleStderr);
    }

    //---------------------------------------------------------------
    public void run() throws Throwable, Exception {
        httpServerStart();
        httpServerWaitTillDone();
        exit();
    }

    //---------------------------------------------------------------
    private Thread onShutdownThread() {
        return new Thread(new Runnable() {
            public void run() {
                PrintWriter messageLog = Settings.getMessageLog();
                if (null == messageLog) return;

                messageLog.println("null ]");
                messageLog.close();
            }
        });
    }

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
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

    //---------------------------------------------------------------
    public void httpServerWaitTillDone() {
        try {
            server.join();
        }
        catch (Throwable e) {
            severeError("exception waiting for server to stop: " + e);
        }
    }

    //---------------------------------------------------------------
    public void serverStarted() {
    }

    //---------------------------------------------------------------
    public void addServerConsoleMessage(String line, boolean stdout) {
    }

    //---------------------------------------------------------------
    public int severeError(String message) {
        Logger.warn(message);
        Logger.warn("exiting...");
        return exit();
    }

}
