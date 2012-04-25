#!/usr/bin/env python

#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------

import os
import re
import sys
import urllib2
import xml.dom
import xml.dom.minidom

Node = xml.dom.Node

URL = "https://issues.apache.org/jira/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?jqlQuery=project+%3D+CB+AND+component+%3D+weinre+AND+status+%3D+Resolved+ORDER+BY+key+ASC&tempMax=1000"

#-------------------------------------------------------------------------------
def main():
    iFile = urllib2.urlopen(URL)
    contents = iFile.read()
    iFile.close()
    
    dom = xml.dom.minidom.parseString(contents)
    items = dom.getElementsByTagName("item")
    
    for item in items:
        title = getText(item, "title").strip()
        link  = getText(item, "link").strip()
        key   = getText(item, "key").strip()
        
        
        title = re.sub(r'^\[.*?\]',"",title,1).strip()
        title = re.sub(r'^\[.*?\]',"",title,1).strip()
        
        print '<li><a href="%s">%s</a>  - %s' % (link, key, title)
    
#-------------------------------------------------------------------------------
def getText(element, childTag=None):
    result = []
    
    if None == childTag:
        elements = element.childNodes
    else:
        elements = element.getElementsByTagName(childTag)
    
    for element in elements:
        if element.nodeType == Node.TEXT_NODE:          result.append(element.data)
        if element.nodeType == Node.CDATA_SECTION_NODE: result.append(element.data)
        if element.nodeType == Node.ENTITY_NODE:        result.append(element.nodeValue)
        if element.nodeType == Node.ELEMENT_NODE:       result.append(getText(element))
            
    return "".join(result)

#-------------------------------------------------------------------------------
def log(message):
    message = "%s: %s" % (PROGRAM_NAME, message)
    print >>sys.stderr, message

#-------------------------------------------------------------------------------
def error(message):
    log(message)
    sys.exit(-1)

#-------------------------------------------------------------------------------
PROGRAM_NAME = os.path.basename(sys.argv[0])

main()
