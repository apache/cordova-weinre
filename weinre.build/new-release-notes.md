<!--
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
-->

steps to create a new release
===============================================================================

- check out project into a new branch, say `release-x.y.z`

- update the `WEINRE_VERSION` variable in `weinre.build/build.properties` as appropriate

- add changelog to `weinre.doc/ChangeLog.body.html`, built with

    weinre.build/scripts/changelog.sh [previous-version]

- fix other doc as necessary

- perform full build with one of:

   - cd into `weinre.build` and run ant

   - in Eclipse, select `weinre build.xml` from the External Tools menu

- run the smoke test (see below) to ensure delicious smoky flavor

- upload the `weinre-jar-x.y.z.zip` and `weinre-mac-x.y.z.zip` files

- make sure you can download those zip files!

- commit release changes:
   - `git add .`
   - `git commit -m update for release x.y.z`

- merge branch onto master:

   - `git checkout master`
   - `git merge --no-ff release-x.y.z`
   - `git push`
   - `git tag -a x.y.z`
   - `git push --tags`

- merge branch onto develop:

   - `git checkout develop`
   - `git merge --no-ff release-x.y.z`
   - `git push`
   - `git branch -d release-x.y.z`

- update github pages:

   - `git checkout gh_pages`
   - `cp -r ~/Projects/weinre/weinre.build/out/web/doc/* .` (or whatever)
   - `git add .`
   - `git commit -m update for release x.y.z`
   - `git push`

- announce to the world!


smoke test
===============================================================================

The smoke test involves testing the three archives:

- `weinre-doc.zip`
- `weinre-mac.zip`
- `weinre-jar.zip`


smoke test - doc
-------------------------------------------------------------------------------

- unzip `weinre-doc.zip`
- browse all pages


smoke test - mac
-------------------------------------------------------------------------------

- unzip `weinre-mac.zip`
- make sure `build-info.txt` looks right
- launch the app
- open a new browser on [http://localhost:8081/demo/weinre-demo.html](http://localhost:8081/demo/weinre-demo.html)
- poke around the demo, make sure it works
- close app
- start server in eclipse
- launch the app
- should get error about port in use

smoke test - jar
-------------------------------------------------------------------------------

- unzip `weinre-jar.zip`
- make sure `build-info.txt` looks right
- run `java -jar weinre.jar --help` make sure help works
- run `java -jar weinre.jar` make sure help works
- poke around the demo, make sure it works
- kill server
- start server in eclipse
- run `java -jar weinre.jar` make sure help works
- should get error about port in use
