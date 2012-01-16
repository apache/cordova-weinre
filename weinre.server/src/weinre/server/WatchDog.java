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
