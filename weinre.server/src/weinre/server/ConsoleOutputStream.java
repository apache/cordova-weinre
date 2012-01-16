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

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;

//-------------------------------------------------------------------
public class ConsoleOutputStream extends OutputStream {

    private Main                 main;
    private PrintStream          originalStream;
    private StringBuffer         stringBuffer;
    private boolean              stdout;

    //---------------------------------------------------------------
    static public PrintStream newPrintStream(Main main, PrintStream originalStream, boolean stdout) {
        return new PrintStream(new ConsoleOutputStream(main, originalStream, stdout));
    }

    //---------------------------------------------------------------
    public ConsoleOutputStream(Main main, PrintStream originalStream, boolean stdout) {
        this.main           = main;
        this.originalStream = originalStream;
        this.stdout         = stdout;
        this.stringBuffer   = new StringBuffer();
    }

    //---------------------------------------------------------------
    @Override
    public void write(int c) throws IOException {
        if (c == 0x0D) return;

        if (c != 0x0A) {
            stringBuffer.append(Character.toChars(c));
            return;
        }

        String line = stringBuffer.toString();
        stringBuffer = new StringBuffer();
        _writeLine(line);
    }

    //---------------------------------------------------------------
    private void _writeLine(String line) {
        originalStream.println(line);

        main.addServerConsoleMessage(line, stdout);
    }

}
