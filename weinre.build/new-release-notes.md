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

   - cd into `weinre.build` and run `ant build-archives`

- run the smoke test (see below) to ensure delicious smoky flavor

- upload the archives wherever

- make sure you can download those archives!

- commit release changes:
   - `git add .`
   - `git commit -m "update for release x.y.z"`

- merge branch onto master:

   - `git checkout master`
   - `git merge --squash release-x.y.z`
   - `git commit -m "update for release x.y.z"`
   - `git push`
   - `git tag -a x.y.z`
   - `git push --tags`

- copy archives into temporary download location
   - currently [http://people.apache.org/~pmuellr/weinre/](http://people.apache.org/~pmuellr/weinre/)
   - see the [`update-latest.sh`](https://github.com/pmuellr/people.apache.org/blob/master/public_html/weinre/update-latest.sh)
     file for an example of automating this

- update npm
   - run `cd weinre.build`
   - run `npm publish`

- update apache cms pages:

   - not ready for prime time

- prepare for blessed Apache version

   - not sure how to do this yet


smoke test
===============================================================================

The smoke test involves testing the archives:

- `apache-cordova-weinre-{VERSION}-bin.{ARCHIVE}`
- `apache-cordova-weinre-{VERSION}-doc.{ARCHIVE}`
- `apache-cordova-weinre-{VERSION}-src.{ARCHIVE}`

The archives are built via `ant build-archives` and are available
in `weinre.build/out/archives`.

smoke test - bin
-------------------------------------------------------------------------------

- unzip the `-bin` archive and `cd` into it
- run `./weinre --help` make sure help works
- run `weinre`
- in your browser open the main page, eg [`http://localhost:8080`](http://localhost:8080)
- poke around the demo, make sure it works
- should add some variations on starting with used port, etc

smoke test - doc
-------------------------------------------------------------------------------

- unzip the `-doc` archive
- browse all pages

smoke test - src
-------------------------------------------------------------------------------

- unzip the `-src` archive and `cd` into it
- run `cd weinre.build`
- run `cp sample.personal.properties personal.properties`
- run `ant build-archives`
- run the smoke test on the built archives, recursively

