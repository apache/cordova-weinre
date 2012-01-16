#!/usr/bin/env python

# ---
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ---

import os
import sys
import json
import httplib

if len(sys.argv) < 3:
    print "expecting parameters <user> <project>"
    sys.exit()

user = sys.argv[1]
proj = sys.argv[2]

url = "/api/v2/json/issues/list/%s/%s/closed" % (user, proj)

conn = httplib.HTTPConnection("github.com")
conn.request("GET", url)
resp = conn.getresponse()
resp = json.loads(resp.read())
conn.close()

issues = resp["issues"]

issues.sort(lambda x,y: cmp(x["number"], y["number"]))

for issue in issues:
    number = issue["number"]
    title  = issue["title"]
    date   = issue["closed_at"]

    template = "<li><a href='https://github.com/%s/%s/issues/%d'>issue %d</a> %s - %s"
    print template % (user, proj, number, number, date, title)