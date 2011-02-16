/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server;

import java.util.List;

//-------------------------------------------------------------------
public class WatchDog {

    public static long ChannelLivelinessTimeout = 5000;
    
    //---------------------------------------------------------------
    static public void start() {

        final WatchDog watchDog = new WatchDog();
        
        Runnable runnable = new Runnable() {
            public void run() { watchDog.run(); } 
        };
        
        Thread thread = new Thread(runnable, watchDog.getClass().getName());
        
        thread.start();
    }
    
    //---------------------------------------------------------------
    private WatchDog() {
        super();
    }
    
    //---------------------------------------------------------------
    private void run() {
        while(true) {
            sleep();
            
            checkForDeadChannels();
        }
    }

    //---------------------------------------------------------------
    private void checkForDeadChannels() {
        List<Channel> channels = ChannelManager.$.getChannels();
        
        int deathTimeout = Main.getSettings().getDeathTimeoutSeconds() * 1000;
        
        long currentTime = System.currentTimeMillis();
        for (Channel channel: channels) {
            long lastRead = channel.getLastRead();
            
            if (currentTime - lastRead > deathTimeout) {
                channel.close();
            }
        }
    }
    
    //---------------------------------------------------------------
    private void sleep() {
        try {
            Thread.sleep(1000);
        } 
        catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}
