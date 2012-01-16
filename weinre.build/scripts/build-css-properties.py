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
import re
import sys
import json
import optparse

#--------------------------------------------------------------------
# reads:
#   http://svn.webkit.org/repository/webkit/trunk/WebCore/css/CSSPropertyNames.in
# writes:
#   json array
#--------------------------------------------------------------------
def main():
    if len(sys.argv) < 3:
        error("expecting parameters inputFile outputFile")

    iFileName = sys.argv[1]
    oFileName = sys.argv[2]

    if not os.path.exists(iFileName): error("input file not found: '" + iFileName + "'")

    with open(iFileName, "r") as iFile:
        lines = iFile.readlines()

    properties = [line.strip() for line in lines if not line.strip().startswith("#")]
    properties = [property for property in properties if property != ""]
    properties.sort()

    jsonString = json.dumps(properties, indent=4)
    jsString = 'require("weinre/common/Weinre").addCSSProperties(%s)' % jsonString

    oFile = open(oFileName, "w")
    oFile.write(jsString)
    oFile.close()

    log("generated css properties in: " + oFileName)

#--------------------------------------------------------------------
def log(message):
    message = "%s: %s" % (PROGRAM_NAME, message)
    print >>sys.stderr, message

#--------------------------------------------------------------------
def error(message):
    log(message)
    sys.exit(-1)

#--------------------------------------------------------------------
PROGRAM_NAME = os.path.basename(sys.argv[0])

main()
