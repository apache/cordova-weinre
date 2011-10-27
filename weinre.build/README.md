building weinre
===============================================================================

The weinre source base consists of file folders:

- `weinre.application`
- `weinre.build`
- `weinre.doc`
- `weinre.server`
- `weinre.web`

weinre was originally built using Eclipse, and still maintains Eclipse meta-data so that it can be developed in Eclipse.  Each of the folders above maps into a separate project.  Note however that the Eclipse-y-ness of the weinre source base is no longer maintained.  Please open a bug if there are problems.

Before running a build, you should copy the `weinre.build/sample.personal.properties` file to the file `weinre.build/personal.properties`, and then customize that file.

weinre requires additional code to produce the final jar.  These dependencies will be downloaded the first time you run a build, and then won't be downloaded for subsequent builds.  You can explicitly get the dependencies by running the `weinre.build/get-vendor.xml` file in Ant, as follows:

    ant -f get-vendor.xml

Various transient directories in this project (weinre.build) will be created after the build.  They are set to not be stored in the SCM.  They include:

- `out`
- `cached`
- `tmp`
- `vendor`

You can delete them whenever you wish, or use the `"clean"` target of the  `weinre.build/build.xml` file to delete them.  Deleting them will cause the build to take longer, to rebuild what you deleted.

The `weinre.build/out` directory in particular contains the final build artifacts:

-  `weinre.build/out/archives/weinre-doc-{version}.zip`

   contains the HTML doc for weinre

-  `weinre.build/out/archives/weinre-jar-{version}.zip`

   contains the platform-portable weinre.jar file

-  `weinre.build/out/archives/weinre-mac-{version}.zip`

   contains the Mac OS X weinre.app application

-  `weinre.build/out/archives/weinre-src-{version}.zip`

   contains the source of the projects (copy of what's in the SCM)

To build while you are developing the weinre code, you can use the quicker-to-build `"build-dev"` target of `weinre.build/build.xml` . This will not build the jars or archives, just rebuilds the bits necessary to run the server transient output directories.
