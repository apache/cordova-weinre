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
#
#--------------------------------------------------------------------
def main():
    
    #----------------------------------------------------------------
    # parse args    
    #----------------------------------------------------------------
    if len(sys.argv) < 4:
        error("expecting parameters piecesHtmlFile srcDir outputDir")
    
    iFileName   = sys.argv[1]
    srcDirName  = sys.argv[2]
    oDirName    = sys.argv[3]
    
    if not os.path.exists(iFileName):   error("input file not found: '" + iFileName + "'")
    if not os.path.exists(srcDirName):  error("source directory not found: '" + srcDirName + "'")
    if not os.path.isdir(srcDirName):   error("source directory not a directory: '" + srcDirName + "'")
    if not os.path.exists(oDirName):    error("output directory not found: '" + oDirName + "'")
    if not os.path.isdir(oDirName):     error("output directory not a directory: '" + oDirName + "'")
    
    #----------------------------------------------------------------
    # read the "pieces" file
    #----------------------------------------------------------------
    with open(iFileName, "r") as iFile:
        lines = iFile.readlines()
        
    #----------------------------------------------------------------
    # get the scripts from the pieces file
    #----------------------------------------------------------------
    scripts     = []
    scriptNames = {}
    scriptSrc   = {}
    scriptMin   = {}
    scriptSrcPattern = re.compile(r'.*?<script\s+src\s*=\s*"/(.*?)"\s*>\s*</script>.*')
    
    for line in lines:
        match = scriptSrcPattern.match(line)
        if not match: continue
        
        baseScriptFile = match.group(1)
        scriptFile = os.path.join(srcDirName, baseScriptFile)
        if not os.path.exists(scriptFile):   error("script file not found: '" + scriptFile + "'")
        
        scripts.append(scriptFile)
        scriptNames[scriptFile] = baseScriptFile

        with open(scriptFile, "r") as iFile:
            scriptSrc[scriptFile] = iFile.read()
            
        scriptMin[scriptFile] = min(scriptSrc[scriptFile])

        # log("read: %s" % scriptFile)

    #----------------------------------------------------------------
    # write the target-script.js file
    #----------------------------------------------------------------
    oFileName = os.path.join(oDirName, "target-script.js")
    writeMergedFile(oFileName, scripts, scriptNames, scriptSrc)

    #----------------------------------------------------------------
    # write the target-script-min.js file
    #----------------------------------------------------------------
    oFileName = os.path.join(oDirName, "target-script-min.js")
    writeMergedFile(oFileName, scripts, scriptNames, scriptMin)

#--------------------------------------------------------------------
#
#--------------------------------------------------------------------
def writeMergedFile(oFileName, scripts, scriptNames, srcs):

    lines = []
    lines.append(";(function(){")
    
    for script in scripts:
        lines.append("//==================================================")
        lines.append("// file: " + scriptNames[script])
        lines.append("//==================================================")
        lines.append(srcs[script])
        lines.append(";")
        lines.append("")

    lines.append("require('weinre/target/Target').main()")
    lines.append("})();")
    targetScript = "\n".join(lines)
    
    with open(oFileName, "w") as oFile:
        oFile.write(targetScript)
    
    log("generated: %s" % oFileName)


#--------------------------------------------------------------------
#
#--------------------------------------------------------------------
def min(script):
    patternCommentC   = re.compile(r"/\*.*?\*/",     re.MULTILINE + re.DOTALL)
    patternCommentCPP = re.compile(r"(?<!\\)//.*?$", re.MULTILINE)
    patternIndent     = re.compile(r"^\s*",          re.MULTILINE)
    patternBlankLine  = re.compile(r"^\s*\n",        re.MULTILINE)

    script = patternCommentC.sub(   "", script)
    script = patternCommentCPP.sub( "", script)
    script = patternIndent.sub(     "", script)
    script = patternBlankLine.sub(  "", script)
    
    return script

#--------------------------------------------------------------------
#
#--------------------------------------------------------------------
def log(message):
    message = "%s: %s" % (PROGRAM_NAME, message)
    print >>sys.stderr, message

#--------------------------------------------------------------------
#
#--------------------------------------------------------------------
def error(message):
    log(message)
    sys.exit(-1)

#--------------------------------------------------------------------
#
#--------------------------------------------------------------------
PROGRAM_NAME = os.path.basename(sys.argv[0])

main()
