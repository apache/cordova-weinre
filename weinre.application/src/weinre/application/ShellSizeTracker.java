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
    private boolean        stop;

    //---------------------------------------------------------------
    static public String getBoundsKey(Shell shell, String name) {
        return "bounds-" + name + "-" + ShellSizeTracker.getMonitorSetupKey(shell.getDisplay());
    }

    //---------------------------------------------------------------
    static private String getMonitorSetupKey(final Display display) {
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
        this.stop         = false;

        shell.addControlListener(new ControlListener() {
            public void controlMoved(ControlEvent e)   {shellMoved();}
            public void controlResized(ControlEvent e) {shellMoved();}
        });

    }

    //---------------------------------------------------------------
    public void start() {
        startWaiterThread();
    }

    //---------------------------------------------------------------
    public void stop() {

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
        key = ShellSizeTracker.getBoundsKey(shell, name);

        preferences.setPreference(key, valueJSON);

        dirty = false;
    }


    //---------------------------------------------------------------
    private Thread startWaiterThread() {
        Runnable runnable = new Runnable() {
            public void run() {
                while (true) {
                    try { Thread.sleep(1000); } catch(InterruptedException e) { return; }

                    if (stop) return;
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
