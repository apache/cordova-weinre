-------------------------------------------------------------------------------
building weinre
-------------------------------------------------------------------------------

weinre is currently built using Eclipse.  You will need a fairly recent version
of Eclipse with the Java IDE tooling installed to use it.

weinre is made up of five Eclipse projects:

   weinre.application
   weinre.build
   weinre.doc
   weinre.server
   weinre.web
   
When initially loaded into Eclipse you will find many errors in the projects.
This is due to the fact that libraries that weinre depends on have not yet
been loaded into the workspace.  To load these libraries, run the Ant
script weinre.build/build.xml from the weinre.build directory.

Ensure the property USE_JAVAC is NOT set in the personal.properties file.
If this property is set, then the java files in the projects will be
compiled with javac instead of being assumed to be built with Eclipse,
which may cause problems since Eclipse is also compiling the java files.

When the Ant script completes successfully, a full build will have taken
place.  The various red X's another issues from Eclipse should be gone.
If not:

- select all projects, right click context menu/Refresh
- use the Eclipse menu item Project/Clean ... 

This should make everything right.

You may want to set the Eclipse preference General/Workspace/Refresh automatically 
to true (checked) so you don't have to Refresh and Clean.

Various transient directories in this project (weinre.build) will be created
after the build.  They are set to not be stored in the SCM.  They include:

   out
   cached
   tmp
   vendor
   
You can delete them whenever you wish, or use the "clean" target of the 
weinre.build/build.xml file to delete them.  Deleting them will cause
the build to take longer, to rebuild what you deleted.

The weinre.build/out directory in particular contains the final
build artifacts:

   weinre.build/out/archives/weinre-doc-{version}.zip
      contains the HTML doc for weinre
   
   weinre.build/out/archives/weinre-jar-{version}.zip
      contains the platform-portable weinre.jar file
      
   weinre.build/out/archives/weinre-mac-{version}.zip
      contains the Mac OS X weinre.app application
      
   weinre.build/out/archives/weinre-src-{version}.zip
      contains the source of the projects (copy of what's in the SCM)
 
To build while you are developing the weinre code, you can use the
quicker-to-build "build-dev" target of weinre.build/build.xml .
This will not build the jars or archives, just rebuilds the bits
neccessary to run the server from the Eclipse workspace.  A shell
script using a Python utility is provided called "build-continuous.sh"
which you can run and it will run the "build-dev" target whenever a
relevant source file has changed in the workspace.

-------------------------------------------------------------------------------
building without eclipse
-------------------------------------------------------------------------------

Ensure the property USE_JAVAC is set in the personal.properties file.
If this property is set, then the java files in the projects will be
compiled with javac instead of being assumed to be built with Eclipse.
