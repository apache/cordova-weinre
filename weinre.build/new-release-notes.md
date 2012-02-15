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

- add changelog to `weinre.doc/ChangeLog.body.html`

- fix other doc as necessary

- perform full build with:

   - cd into `weinre.build` and run ant

- run the smoke test (see below) to ensure delicious smoky flavor

- upload the `weinre-*-x.y.z.zip`

- make sure you can download those zip files!

- commit release changes:
   - `git add .`
   - `git commit -m "update for release x.y.z"`

- merge branch onto master:

   - `git checkout master`
   - `git merge release-x.y.z`
   - `git push`
   - `git tag -a x.y.z`
   - `git push --tags`

- update apache cms pages:

   - not sure how to do this yet

- prepare for blessed Apache version

   - not sure how to do this yet


smoke test
===============================================================================

The smoke test involves testing the archives:

- `weinre-doc.zip`
- `weinre-node.zip`


smoke test - doc
-------------------------------------------------------------------------------

- unzip `weinre-doc.zip`
- browse all pages


smoke test - node
-------------------------------------------------------------------------------

- unzip `weinre-node.zip`
- make sure `build-info.txt` looks right
- run `weinre --help` make sure help works
- run `weinre` make sure help works
- poke around the demo, make sure it works
- should add some variations on starting with used port, etc