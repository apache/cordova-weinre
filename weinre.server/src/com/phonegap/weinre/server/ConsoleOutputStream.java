/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, IBM Corporation
 */

package com.phonegap.weinre.server;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;

/**
 * 
 */
public class ConsoleOutputStream extends OutputStream {

    private Main                 main;
    private PrintStream          originalStream;
    private StringBuffer         stringBuffer;
    private boolean              stdout;

    /**
     * 
     */
    static public PrintStream newPrintStream(Main main, PrintStream originalStream, boolean stdout) {
        return new PrintStream(new ConsoleOutputStream(main, originalStream, stdout));
    }
    
    /**
     * 
     */
    public ConsoleOutputStream(Main main, PrintStream originalStream, boolean stdout) {
        this.main           = main;
        this.originalStream = originalStream;
        this.stdout         = stdout;
        this.stringBuffer   = new StringBuffer();
    }
    
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

    /**
     * 
     */
    private void _writeLine(String line) {
        originalStream.println(line);
        
        main.addServerConsoleMessage(line, stdout);
    }

}
