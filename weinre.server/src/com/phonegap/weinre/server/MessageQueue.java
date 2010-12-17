/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * A type of blocking queue.
 * 
 * - can be shutdown; subsequent add() or getAll() calls throw ISE
 * - getAll() takes all items off the queue
 * - if there are simultaneous getAll() calls, queued items may be split between them 
 * - current use case calls for one reader, so previous item not relevant
 */
public class MessageQueue<E> {

    private BlockingQueue<E> queue;
    private boolean          closed;
    private Object           closeLock;
    
    /**
     * 
     */
    public MessageQueue() {
        super();
        
        queue     = new LinkedBlockingQueue<E>();
        closed    = false;
        closeLock = new Object();
    }
    
    /**
     * 
     */
    public void shutdown() {
        synchronized(closeLock) {
            if (closed) return;
            
            closed = true;
            queue.clear();
        }
    }
    
    /**
     * 
     */
    public void add(E item) {
        synchronized(closeLock) {
            if (closed) throw new IllegalStateException("the blocking queue is closed");
        }

        queue.add(item);
    }
    
    /**
     * 
     */
    public List<E> getAll(int timeout, TimeUnit timeUnit) throws InterruptedException {
        synchronized(closeLock) {
            if (closed) throw new IllegalStateException("the blocking queue is closed");
        }

        // create our result list
        List<E> result = new LinkedList<E>();
        
        // wait for the first item
        E item = queue.poll(timeout, timeUnit);
        
        // nothing there?  return empty list
        if (null == item) return result;

        // add the first item to the list
        result.add(item);

        // get anything else on the queue
        // - not appropriate for simultaneous calls to this method
        while ((item = queue.poll()) != null) {
            result.add(item);
        }
        
        // return list
        return result;
    }
    
    /**
     * 
     */
    public String toString()  {
        return getClass().getName() + "{" + queue.size() + "}";
    }
}
