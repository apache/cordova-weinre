/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

/**
 * 
 */
public class ServerSettings {

    final static private String BoundHostAllConstant = "-all-";
    
    private int         httpPort           = 8080;
    private String      boundHost          = "localhost";
//  private boolean     useProxy           = false;
    private boolean     reuseAddr          = true;
    private boolean     verbose            = false;
    private int         readTimeoutSeconds = 5;
    private int         deathTimeoutSeconds;
    private Properties  fileProperties;
    
    /**
     * 
     */
    static public ServerSettings getOptions(String[] commandLine) {
        ServerSettings settings = new ServerSettings();
        return settings.parse(commandLine);
    }

    /**
     * 
     */
    private ServerSettings() {
        super();
        
        fileProperties = fromPropertiesFile();
    }

    /**
     * 
     */
    private Options getOptions() {
        Options options = new Options();
       
        options.addOption("?",            false, "display help");
        options.addOption("h", "help",    false, "display help");
        options.addOption("httpPort",     true,  "tcp/ip port to use for the http server");
        options.addOption("boundHost",    true,  "host address to bind to");
        options.addOption("verbose",      true,  "display verbose logging information [true|false]");
//      options.addOption("useProxy",     true,  "enable HTTP proxy [true|false]");
        options.addOption("reuseAddr",    true,  "force bind the port if already bound [true|false]");
        options.addOption("readTimeout",  true,  "seconds before timing out HTTP GETs");
        options.addOption("deathTimeout", true,  "seconds before considering connector dead");
       
        return options;
    }

    /**
     * 
     */
    public Map<String,Object> asProperties() {
        Map<String,Object> result = new HashMap<String,Object>();

        result.put("httpPort",     this.httpPort + "");
        result.put("boundHost",    this.boundHost);
        result.put("boundHosts",   this.getBoundHosts());
        result.put("verbose",      this.verbose + "");
//      result.setProperty("useProxy",     this.useProxy + "");
        result.put("reuseAddr",    this.reuseAddr + "");
        result.put("readTimeout",  this.readTimeoutSeconds + "");
        result.put("deathTimeout", this.deathTimeoutSeconds + "");
        
        return result;
    }

    /**
     * 
     */
    private Properties fromPropertiesFile() {
        Properties result = Utility.readPropertiesFile("server.properties");
        
        // ya, Properties doesn't trim space off values
        for (String key: result.stringPropertyNames()) {
            String val = result.getProperty(key);
            result.setProperty(key, val.trim());
        }
        
        return result;
    }

    
    /**
     * 
     */
    private ServerSettings parse(String[] commandLineArgs) {
        Options options = getOptions();

        CommandLineParser parser = new PosixParser();
        CommandLine       commandLine;
        try {
            commandLine = parser.parse(options, commandLineArgs);
        } 
        catch (ParseException e) {
            error(e.getMessage());
            return null;
        }

        // handle help
        if (commandLine.hasOption("?") || commandLine.hasOption("h")) {
            printHelp(options);
            return null;
        }

        // get values
        httpPort            = getIntFromOption(commandLine,     "httpPort",     httpPort,             0, 0x00FFFF);
        boundHost           = getStringFromOption(commandLine,  "boundHost",    boundHost);
        verbose             = getBooleanFromOption(commandLine, "verbose",      verbose);
//      useProxy            = getBooleanFromOption(commandLine, "useProxy",     useProxy);
        reuseAddr           = getBooleanFromOption(commandLine, "reuseAddr",    reuseAddr);
        readTimeoutSeconds  = getIntFromOption(commandLine,     "readTimeout",  readTimeoutSeconds,   0, 0x00FFFFFF);
        deathTimeoutSeconds = getIntFromOption(commandLine,     "deathTimeout", readTimeoutSeconds*3, 0, 0x00FFFF);

        // handle verbose logging
        if (commandLine.hasOption("verbose")) {
            verbose = true;
        }

        return this;
    }

    /**
     * 
     */
    private int getIntFromOption(CommandLine commandLine, String name, int defaultValue, int min, int max) {
        int result = defaultValue;
        
        String stringValue = commandLine.getOptionValue(name);
        if (null == stringValue) {
            stringValue = fileProperties.getProperty(name);
        }

        if (null == stringValue) return defaultValue;
            
        try {
            result = Integer.parseInt(stringValue);
        }
        catch (NumberFormatException e) {
            error(name + " parameter must be numeric");
            return result;
        }
        
        if ((result < min) || (result > 0x00FFFF)) {
            error(name + " parameter must be between " + min + " and " + max);
        }

        return result;
    }
    
    /**
     * 
     */
    private String getStringFromOption(CommandLine commandLine, String name, String defaultValue) {
        String stringValue = commandLine.getOptionValue(name);
        if (null == stringValue) {
            stringValue = fileProperties.getProperty(name);
        }

        if (null == stringValue) return defaultValue;
        
        return stringValue;
    }
    
    /**
     * 
     */
    private boolean getBooleanFromOption(CommandLine commandLine, String name, boolean defaultValue) {
        boolean result = defaultValue;
        
        String stringValue = commandLine.getOptionValue(name);
        if (null == stringValue) {
            stringValue = fileProperties.getProperty(name);
        }

        if (null == stringValue) return defaultValue;
            
        result = Boolean.parseBoolean(stringValue);

        return result;
    }
    
    /**
     * 
     */
    private void error(String message) {
        System.out.println("error with command-line option: " + message);
    }
    
    /**
     * 
     */
    private void printHelp(Options options) {
        new HelpFormatter().printHelp("java -jar weinre.jar [options]", options);
    }
    
    /**
     * 
     */
    public int getHttpPort() {
        return httpPort;
    }
    
    /**
     * 
     */
    public String getBoundHost() {
        return boundHost;
    }
    
    /**
     * 
     */
    public String[] getBoundHosts() {
        if (getBoundHostValue() != null) {
            return new String[] { getBoundHost() };
        }
        
        ArrayList<String> hosts = new ArrayList<String>();
        List<NetworkInterface> networkInterfaces;
        try {
            networkInterfaces = Collections.list(NetworkInterface.getNetworkInterfaces());
        }
        catch (SocketException e) {
            return new String[]{"localhost"};
        }
    
        for (NetworkInterface networkInterface: networkInterfaces) {
            List<InetAddress> inetAddresses = Collections.list(networkInterface.getInetAddresses());
            
            for (InetAddress inetAddress: inetAddresses) {
                hosts.add(inetAddress.getHostName());
            }
        }
        
        return hosts.toArray(new String[]{});
    }
    
    /**
     * 
     */
    public String getBoundHostValue() {
        if (BoundHostAllConstant.equals(boundHost)) return null;
        
        return boundHost;
    }
    
    /**
     * 
     */
    public boolean getVerbose() {
        return verbose;
    }
    
    /**
     * 
     */
    public int getReadTimeoutSeconds() {
        return readTimeoutSeconds;
    }
    
    /**
     * 
     */
    public int getDeathTimeoutSeconds() {
        return deathTimeoutSeconds;
    }
    
    /**
     * 
     */
    public boolean useProxy() {
        return false; // useProxy;
    }
    
    /**
     * 
     */
    public boolean reuseAddr() {
        return reuseAddr;
    }
    
    /**
     * 
     */
    public String getNiceHostName() {
        String hostName = getBoundHostValue();
        if (null == hostName) return "localhost";
        return hostName;
    }
        
    /**
     *
     */
    @SuppressWarnings("unused")
    private String getSuperNiceHostName() {
        String hostName = getBoundHost();
        
        // get the host address used
        InetAddress inetAddress;
        try {
            inetAddress = InetAddress.getByName(hostName);
        }
        catch (UnknownHostException e) {
            Main.warn("Unable to get host address of " + hostName);
            return null;
        }

        // if it's "any local address", deal with that
        if (inetAddress.isAnyLocalAddress()) {
            try {
                InetAddress oneAddress = InetAddress.getLocalHost();
                return oneAddress.getHostName();
            }
            catch (UnknownHostException e) {
                Main.warn("Unable to get any local host address");
                return null;
            }
        }

        return inetAddress.getHostName();
    }
}
