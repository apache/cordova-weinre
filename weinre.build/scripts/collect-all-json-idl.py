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
    if len(sys.argv) < 3:
        error("expecting parameters outputFile inputDir")

    min = False
    if sys.argv[1] == "-min":
        min = True
        oFileName = sys.argv[2]
        iDirName  = sys.argv[3]

    else:
        oFileName = sys.argv[1]
        iDirName  = sys.argv[2]

    entries  = os.listdir(iDirName)
    if 0 == len(entries): error("no files found in '" + iDirName + "'")

    entries = [entry for entry in entries if entry.endswith(".json")]
    if 0 == len(entries): error("no JSON files found in '" + iDirName + "'")

    result = []
    for entry in entries:
        iFileName = os.path.join(iDirName, entry)
        if not os.path.exists(iFileName): error("File not found: '" + iFileName + "'")

        iFile = open(iFileName, "r")
        contents = iFile.read()
        iFile.close()

        result.append(json.loads(contents))

    if min:
        result = minimize(result)
        jsonString = json.dumps(result)

    else:
        jsonString = json.dumps(result, indent=4)

    jsString = "modjewel.require('weinre/common/Weinre').addIDLs(%s)" % jsonString

    oFile = open(oFileName, "w")
    oFile.write(jsString)
    oFile.close()

    log("generated collected json idls in: " + oFileName)

#--------------------------------------------------------------------
def minimize(idl):
    for module in idl:
        for interface in module["interfaces"]:
            if "extendedAttributes" in interface:
                del interface["extendedAttributes"]

            if "methods" in interface:
                for method in interface["methods"]:
                    if "returns" in method:
                        del method["returns"]
                    if "callbackParameters" in method:
                        del method["callbackParameters"]
                    if "extendedAttributes" in method:
                        del method["extendedAttributes"]

                    if "parameters" in method:
                        for parameter in method["parameters"]:
                            if "type" in parameter:
                                del parameter["type"]

    return idl

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
