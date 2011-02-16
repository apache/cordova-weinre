#!/usr/bin/env python

# ---
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
# 
# Copyright (c) 2010, 2011 IBM Corporation
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
        
    jsonString = json.dumps(result, indent=4)
    jsString = "require('weinre/common/Weinre').addIDLs(%s)" % jsonString

    oFile = open(oFileName, "w")
    oFile.write(jsString)
    oFile.close()
    
    log("generated collected json idls in: " + oFileName)

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
