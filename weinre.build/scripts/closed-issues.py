#!/usr/bin/env python

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