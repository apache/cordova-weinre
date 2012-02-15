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

The files contained in this directory are the source for the
weinre server, implemented using the 
[express package](http://expressjs.com/)
on the 
[node.js](http://nodejs.org) 
runtime.

The weinre server uses numerous 3rd party libraries, installed in the
`node_modules` directory, and stored in the SCM.  
In case these need to be updated, the file
`package.json` should be updated with the dependencies and versions
needed, then run

	rm -rf node_modules; npm install

to refresh the dependencies.


before running the weinre server
--------------------------------

Before running the weinre server, after downloading the source,
you will need to run a 'build'.


running the weinre server
-------------------------

