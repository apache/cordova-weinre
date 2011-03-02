package weinre.server.android;

import android.app.Activity;
import android.os.Bundle;

import weinre.server.Main;
import weinre.server.android.R;

//---------------------------------------------------------------------------------
public class MainActivity extends Activity {
    
    private Main main;

    //-----------------------------------------------------------------------------
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setContentView(R.layout.main);
        
        //-------------------------------------------------------------------------
        main = new Main(new String[]{"--boundHost", "-all-", "--readTimeout", "30"});
        
        Runnable serverRunnable = new Runnable() {
            public void run() {
                main.httpServerStart();
                String[] hosts = Main.getSettings().getBoundHosts();
                System.out.println("Bound Hosts:");
                for (String host: hosts) {
                    System.out.println("   " + host);
                }
            }
        };

        new Thread(serverRunnable, "main server thread").start();
    }
   
}