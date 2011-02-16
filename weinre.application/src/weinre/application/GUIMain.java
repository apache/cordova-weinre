/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.application;

import java.io.IOException;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;
import org.eclipse.swt.SWT;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.layout.FormAttachment;
import org.eclipse.swt.layout.FormData;
import org.eclipse.swt.layout.FormLayout;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

import weinre.server.Main;
import weinre.server.ServerSettings;

//-------------------------------------------------------------------
public class GUIMain extends Main {
    private Display        display;
    private Shell          shell;
    private Browser        debugger;
    private StyledText     console;
    private Browser        homePage;
    private Color          red;
    private GUIPreferences preferences;
    
    //---------------------------------------------------------------
    static public void main(String[] args) {
        GUIMain main = new GUIMain(args);
        main.run();
    }

    //---------------------------------------------------------------
    public GUIMain(String[] args) {
        super(args);
        
        preferences = new GUIPreferences();
    }
    
    //---------------------------------------------------------------
    public void run() {
        uiBuild();

        Runnable serverRunnable = new Runnable() {
            public void run() {
                httpServerStart();
            }
        };
        
        new Thread(serverRunnable, "main server thread").start();

        uiRun();
        
        exit();
    }

    //---------------------------------------------------------------
    public GUIPreferences getPreferences() {
        return preferences;
    }
    
    //---------------------------------------------------------------
    public void uiBuild() {
        Display.setAppName("weinre");
        Display.setAppVersion("???");
        
        display = new Display();
        shell   = new Shell(display);
        
        red = new Color(display, 255, 0, 0);

        shell.setText("weinre - Web Inspector Remote");
        
        CTabFolder tabFolder       = new CTabFolder(shell, SWT.BORDER);
        CTabItem   tabItemDebugger = createTabItem(tabFolder, "Debugger");
        CTabItem   tabItemConsole  = createTabItem(tabFolder, "Server Console");
        CTabItem   tabItemHomePage = createTabItem(tabFolder, "Server Home Page");

        debugger = new Browser(tabFolder, SWT.NONE);
        tabItemDebugger.setControl(debugger);
        
        console = new StyledText(tabFolder, SWT.MULTI | SWT.H_SCROLL | SWT.V_SCROLL);
        console.setEditable(false);
        console.setFont(getMonospaceFont(console));

        homePage = new Browser(tabFolder, SWT.NONE);
        tabItemHomePage.setControl(homePage);
        
        tabItemConsole.setControl(console);
        
        fillParent(debugger,  0, 0, 0, 0);
        fillParent(console,   0, 0, 0, 0);
        fillParent(homePage,  0, 0, 0, 0);
        fillParent(tabFolder, 5, 5, 5, 5);
        
        tabFolder.pack();
        createMenuBar();
        
        new ShellSizeTracker("main", shell, preferences);
        
        try {
            String       boundsKey = preferences.getBoundsKey(shell, "main");
            JSONObject   bounds    = preferences.getPreferenceFromJSON(boundsKey);
            
            if (null != bounds) {
                Integer x, y, w, h;
                try {
                    x = bounds.getInt("x");
                    y = bounds.getInt("y");
                    w = bounds.getInt("width");
                    h = bounds.getInt("height");
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
                
                if ((null != w) && (null != h)) {
                    shell.setBounds(x,y,w,h);
                }
            }
            
            else {
                shell.setBounds(100, 100, 500, 300);
            }
            
        }
        catch (IOException e) {
            Main.warn("exception reading preferences: " + e);
        }
        
    }
 
    //---------------------------------------------------------------
    private void createMenuBar() {
//        Menu menu = new Menu(shell, SWT.BAR);
//        shell.setMenuBar(menu);
//        MenuItem fileMenuItem = new MenuItem(menu, SWT.CASCADE);
//        fileMenuItem.setText("File");
//        MenuItem editMenuItem = new MenuItem(menu, SWT.CASCADE);
//        editMenuItem.setText("Edit");
     }        

    //---------------------------------------------------------------
    public void uiRun() {
        shell.open();
        
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch())
                display.sleep();
        }
        display.dispose();
    }

    //---------------------------------------------------------------
    public CTabItem createTabItem(CTabFolder tabFolder, String text) {
        CTabItem tabItem = new CTabItem(tabFolder, SWT.NONE);
        tabItem.setText(text);
        
        Font       font     = tabItem.getFont();
        FontData[] fontData = font.getFontData();
        
        for (FontData fontDatum: fontData) {
            double newHeight = fontDatum.getHeight() * 1.25;
            fontDatum.setHeight((int) newHeight);
        }
        
        font = new Font(display, fontData);
        tabItem.setFont(font);
        
        return tabItem;
    }
    
    //---------------------------------------------------------------
    public void fillParent(Control control, int marginT, int marginR, int marginB, int marginL ) {
        FormLayout formLayout = new FormLayout();
        
        formLayout.marginTop    = marginT; 
        formLayout.marginBottom = marginB;
        formLayout.marginLeft   = marginL;
        formLayout.marginRight  = marginR;
        
        FormData formData = new FormData();
        
        formData.left     = new FormAttachment(0);
        formData.right    = new FormAttachment(100);
        formData.top      = new FormAttachment(0);
        formData.bottom   = new FormAttachment(100);

        control.getParent().setLayout(formLayout);
        control.setLayoutData(formData);
    }
    
    //---------------------------------------------------------------
    public void serverStarted() {
        debugger.getDisplay().asyncExec(new Runnable() {
            public void run() {
                debugger.setUrl(getBrowserURL() + "client/index.html");
                homePage.setUrl(getBrowserURL() + "index.html");
            }
        });
    }
    
    //---------------------------------------------------------------
    public String getBrowserURL() {
        String result;
        
        ServerSettings settings = weinre.server.Main.getSettings();
        
        String host = settings.getNiceHostName();
        int    port = settings.getHttpPort();
        
        result = "http://" + host + ":" + port + "/";
        
        return result;
    }
    
    
    //---------------------------------------------------------------
    public void addServerConsoleMessage(final String line, final boolean stdout) {
        if (null == console) return;
        
        if (console.isDisposed()) return;
        
        console.getDisplay().asyncExec(new Runnable() {
           public void run() {
               if (console.isDisposed()) return;
               
               String theLine = line + Text.DELIMITER;
               
               Color color = null;
               if (!stdout) color = red;

               StyleRange styleRange = new StyleRange();
               styleRange.start      = console.getCharCount();
               styleRange.length     = theLine.length();
               styleRange.foreground = color;
               
               console.append(theLine);
               console.setStyleRange(styleRange);
           }
        });
    }
    
    
    //---------------------------------------------------------------
    @Override
    public int severeError(final String message) {
        if (null == display) return super.severeError(message);
        if (display.isDisposed()) return super.severeError(message);
        
        display.syncExec(new Runnable() {
           public void run() {
               boolean noGUI = false;
               if (null == display)      noGUI = true;
               if (null == shell)        noGUI = true;
               if (display.isDisposed()) noGUI = true;
               if (shell.isDisposed())   noGUI = true;
               
               if (noGUI) {
                   GUIMain.super.severeError(message);
                   return;
               }
               
               MessageBox messageBox = new MessageBox(shell, SWT.ICON_ERROR | SWT.OK);
               messageBox.setMessage(message);
               messageBox.setText("weinre exiting");
               messageBox.open();
               exit();
           }
        });
        
        return 0;
    }
    
    //---------------------------------------------------------------
    private Font getMonospaceFont(Control control) {
        FontData[] fontData = control.getDisplay().getFontList(null, true);
        
        FontData fontFound = null;
        
        // essentially the defaults that web inspector uses
        if (null == fontFound) fontFound = findFontNamed(fontData, "Menlo");
        if (null == fontFound) fontFound = findFontNamed(fontData, "Monaco");
        if (null == fontFound) fontFound = findFontNamed(fontData, "Consolas");
        if (null == fontFound) fontFound = findFontNamed(fontData, "Lucida Console");
        if (null == fontFound) fontFound = findFontNamed(fontData, "dejavu sans mono");
        if (null == fontFound) fontFound = findFontNamed(fontData, "Courier");
        
        if (null == fontFound) return null;

        fontFound.setHeight(14);
        
        return new Font(control.getDisplay(), fontFound);
    }
    
    //---------------------------------------------------------------
    private FontData findFontNamed(FontData[] fontData, String name) {
        for (FontData fontDatum: fontData) {
            if (fontDatum.getStyle() != SWT.NORMAL) continue;
            if (name.equals(fontDatum.getName())) return fontDatum; 
        }
        
        return null;
    }
    
    //---------------------------------------------------------------
    @SuppressWarnings("unused")
    private void dumpFontData(FontData[] fontData) {
        for (FontData fontDatum: fontData) {
            int    style       = fontDatum.getStyle();
            String styleString = "";
            
            if (0 != (style & SWT.NORMAL)) styleString += "NORMAL ";
            if (0 != (style & SWT.BOLD))   styleString += "BOLD ";
            if (0 != (style & SWT.ITALIC)) styleString += "ITALIC ";
            
            styleString = styleString.trim();
            
            System.out.println("font: " + fontDatum.getName() + " : " + fontDatum.getHeight() + " : " + styleString);
        }
    }
    
}
