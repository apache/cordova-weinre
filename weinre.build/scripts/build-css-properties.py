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
    jsString = 'require("weinre/common/Weinre").getClass().addCSSProperties(%s)' % jsonString

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
