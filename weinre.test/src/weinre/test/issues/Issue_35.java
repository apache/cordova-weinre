/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

package weinre.test.issues;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;

import org.apache.wink.json4j.JSONArray;

//-------------------------------------------------------------------
public class Issue_35 {

  //-------------------------------------------------------------------
static public void main(String[] args) throws Throwable {
    new Issue_35().main();
}

//-------------------------------------------------------------------
private void main() throws Throwable {
    InputStream iStream = getClass().getResourceAsStream("Issue_35.txt");
    
    Reader reader = new InputStreamReader(iStream);
    
    char buffer[] = new char[4096];
    int len       = reader.read(buffer,0,buffer.length);
//    String data   = String.valueOf(buffer, 0, len);
    String data   = String.valueOf(buffer, 1, len-2);
    
    reader.close();
    
    new JSONArray(data);
    
}

}
