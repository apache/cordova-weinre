/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.server;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

//-------------------------------------------------------------------
public class ScriptEventQueue {

    static public ScriptEventQueue $ = new ScriptEventQueue();
    
    private BlockingQueue<String> queue;
    private AtomicBoolean         closed;
    
    //---------------------------------------------------------------
    private ScriptEventQueue() {
        super();
        
        this.queue = new LinkedBlockingQueue<String>();
        this.closed = new AtomicBoolean(false);
    }

    //---------------------------------------------------------------
    public void close() {
        closed.set(true);
    }
    
    //---------------------------------------------------------------
    public boolean isClosed() {
        return closed.get();
    }

    //---------------------------------------------------------------
    public void add(String item) {
        if (isClosed()) return;
        
        queue.add(item);
    }
    
    //---------------------------------------------------------------
    public String getNext() {
        if (isClosed()) return null;
        
        String result;

        try {
            result = queue.poll(5, TimeUnit.SECONDS);
        }
        catch (InterruptedException e) {
            result = null;
        }
        
        return result;
    }
    
}
