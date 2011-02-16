/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.application;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Monitor;
import org.eclipse.swt.widgets.Shell;

//-------------------------------------------------------------------
public class ShellSizeTracker {

    private String         name;
    private Shell          shell;
    private GUIPreferences preferences;
    private boolean        dirty;
    private Point          lastSize;
    private Point          lastLocation;
    private long           lastChange;

    //---------------------------------------------------------------
    static public String getMonitorSetupKey(final Display display) {
        StringBuffer keyBuffer = new StringBuffer();

        Monitor[] monitors = display.getMonitors();
        for (Monitor monitor: monitors) {
            Rectangle bounds     = monitor.getBounds();
            Rectangle clientArea = monitor.getClientArea();
            
            keyBuffer.append("__");
            keyBuffer.append(bounds.x);      keyBuffer.append("_");
            keyBuffer.append(bounds.y);      keyBuffer.append("_");
            keyBuffer.append(bounds.width);  keyBuffer.append("_");
            keyBuffer.append(bounds.height);
            
            keyBuffer.append("__");
            keyBuffer.append(clientArea.x);      keyBuffer.append("_");
            keyBuffer.append(clientArea.y);      keyBuffer.append("_");
            keyBuffer.append(clientArea.width);  keyBuffer.append("_");
            keyBuffer.append(clientArea.height); 
        }

        keyBuffer.insert(0, "monitor-setup");
        
        return keyBuffer.toString();
    }
    
    //---------------------------------------------------------------
    public ShellSizeTracker(String name, final Shell shell, GUIPreferences preferences) {
        super();
        
        this.name         = name;
        this.shell        = shell;
        this.preferences  = preferences;
        this.dirty        = false;
        this.lastSize     = new Point(0,0);
        this.lastLocation = new Point(0,0);
        
        shell.addControlListener(new ControlListener() {
            public void controlMoved(ControlEvent e)   {shellMoved();}
            public void controlResized(ControlEvent e) {shellMoved();}
        });
        
        System.out.println("monitor key: " + getMonitorSetupKey(shell.getDisplay()));
        startWaiterThread();
    }

    //---------------------------------------------------------------
    private void shellMoved() {
        dirty        = true;
        lastChange   = System.currentTimeMillis();
        lastLocation = shell.getLocation();
        lastSize     = shell.getSize();
    }

    //---------------------------------------------------------------
    private void checkForChanges() {
        if (!dirty) return;
        if (shell.isDisposed()) return;
        if (System.currentTimeMillis() < lastChange + 3000) return;
        
        JSONObject valueJSON = new JSONObject();
        
        try {
            valueJSON.put("x", lastLocation.x);
            valueJSON.put("y", lastLocation.y);
            valueJSON.put("width", lastSize.x);
            valueJSON.put("height", lastSize.y);
        } catch (JSONException e1) {
            throw new RuntimeException(e1);
        }
        
        String key;
        String val;
        key = preferences.getBoundsKey(shell, name);
        val = valueJSON.toString();
        
        preferences.setPreference(key, val);
        preferences.saveToFile();
        
        dirty = false;
    }


    //---------------------------------------------------------------
    private Thread startWaiterThread() {
        Runnable runnable = new Runnable() {
            public void run() {
                while (true) {
                    try { Thread.sleep(1000); } catch(InterruptedException e) { return; }
                    
                    if (shell.isDisposed()) return;
                    
                    shell.getDisplay().asyncExec(new Runnable() {
                        public void run() { checkForChanges(); }
                    });
                }
            }
        };
        
        Thread thread = new Thread(runnable, getClass().getSimpleName() + " for " + name);
        thread.start();
        
        return thread;
    }

}
