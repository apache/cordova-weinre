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
def main():
    if len(sys.argv) < 2:
        error("expecting parameters [web directory]")

    webDir = sys.argv[1]

    iFileName = os.path.join(webDir, "client/inspector.html")
    oFileName = os.path.join(webDir, "client/index.html")
    moduleDir = os.path.join(webDir, "weinre")

    if not os.path.exists(iFileName): error("file does not exist: %s" % iFileName)
    if not os.path.exists(moduleDir): error("module directory does not exist: %s" % moduleDir)
    if not os.path.isdir(moduleDir):  error("module directory is not a directory: %s" % moduleDir)

    createIndexFile(iFileName, oFileName, moduleDir)

#--------------------------------------------------------------------
def createIndexFile(iFileName, oFileName, moduleDir):
    with open(iFileName) as iFile: lines = iFile.readlines()

    pattern_head_start = re.compile(r"^\s*<meta http-equiv=\"content-type\".*$")
    pattern_head_end   = re.compile(r"^\s*</head>\s$")

    newLines   = []
    foundStart = False
    foundEnd   = False
    for line in lines:
        if pattern_head_start.match(line):
            foundStart = True
            newLines.append(line)

            newLines.append("<!-- ========== weinre additions: starting ========== -->\n")
            newLines.extend([
                '<meta http-equiv="X-UA-Compatible" content="chrome=1">\n'
                '<link rel="shortcut icon" href="../images/weinre-icon-64x64.png">\n',
                '<title>weinre</title>\n',
                '<script type="text/javascript" src="weinre/browser-support-check.js"></script>\n',
                '<script type="text/javascript" src="weinre/hacks.js"></script>\n',
                '<script type="text/javascript" src="../modjewel.js"></script>\n',
                '<script type="text/javascript">modjewel.require("modjewel").warnOnRecursiveRequire(true)</script>\n',
            ])

            for module in getModules(moduleDir):
                newLines.append('<script type="text/javascript" src="../%s"></script>\n' % module)

            newLines.append("<!-- ========== weinre additions: done ========== -->\n")

        elif pattern_head_end.match(line):
            foundEnd = True
            newLines.append("<!-- ========== weinre additions: starting ========== -->\n")
            newLines.append('<link rel="stylesheet" type="text/css" href="weinre/client.css">\n')
            newLines.append('<script type="text/javascript" src="../interfaces/all-json-idls-min.js"></script>\n')
            newLines.append('<script type="text/javascript">modjewel.require("weinre/client/Client").main()</script>\n')
            newLines.append("<!-- ========== weinre additions: done ========== -->\n")
            newLines.append(line)

        else:
            newLines.append(line)

    if not foundStart: error("didn't find the location to start writing")
    if not foundEnd:   error("didn't find the location to finish writing")

    with open(oFileName, "w") as oFile: oFile.writelines(newLines)

    log("created %s" % oFileName)

#--------------------------------------------------------------------
def getModules(moduleDir):
    modules = []

    for module in os.listdir(os.path.join(moduleDir, "common")):
        modules.append("weinre/common/%s" % module)

    for module in os.listdir(os.path.join(moduleDir, "client")):
        modules.append("weinre/client/%s" % module)

    return modules

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
