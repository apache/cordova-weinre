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

    #----------------------------------------------------------------
    if len(sys.argv) < 3:
        error("expecting parameters srcDir outputDir")

    srcDirName  = sys.argv[1]
    oDirName    = sys.argv[2]

    if not os.path.exists(srcDirName):  error("source directory not found: '" + srcDirName + "'")
    if not os.path.isdir(srcDirName):   error("source directory not a directory: '" + srcDirName + "'")
    if not os.path.exists(oDirName):    error("output directory not found: '" + oDirName + "'")
    if not os.path.isdir(oDirName):     error("output directory not a directory: '" + oDirName + "'")

    #----------------------------------------------------------------
    scripts     = []
    scriptNames = {}
    scriptSrc   = {}
    scriptMin   = {}

    includedFiles = []
    includedFiles.append("modjewel-require.js")

    entries = os.listdir(os.path.join(srcDirName, "weinre/common"))
    for entry in entries:
        includedFiles.append("weinre/common/%s" % entry)

    entries = os.listdir(os.path.join(srcDirName, "weinre/target"))
    for entry in entries:
        includedFiles.append("weinre/target/%s" % entry)

    includedFiles.append("interfaces/all-json-idls-min.js")

    for includedFile in includedFiles:
        baseScriptFile = includedFile
        scriptFile = os.path.join(srcDirName, baseScriptFile)
        if not os.path.exists(scriptFile):
            error("script file not found: '" + scriptFile + "'")

        scripts.append(scriptFile)
        scriptNames[scriptFile] = baseScriptFile

        with open(scriptFile, "r") as iFile:
            scriptSrc[scriptFile] = iFile.read()

        scriptMin[scriptFile] = min(scriptSrc[scriptFile])

        # log("read: %s" % scriptFile)

    #----------------------------------------------------------------
    oFileName = os.path.join(oDirName, "target-script.js")
    writeMergedFile(oFileName, scripts, scriptNames, scriptSrc, True)

    #----------------------------------------------------------------
    oFileName = os.path.join(oDirName, "target-script-min.js")
    writeMergedFile(oFileName, scripts, scriptNames, scriptMin, False)

#--------------------------------------------------------------------
def writeMergedFile(oFileName, scripts, scriptNames, srcs, useEval):
    lines = []
    lines.append(";(function(){")

    for script in scripts:

        src     = srcs[script]
        srcName = scriptNames[script]
        if not useEval:
            lines.append("// %s" % srcName)
            lines.append(src)
            lines.append(";")
        else:
            src = "%s\n//@ sourceURL=%s" % (src, srcName)
            lines.append(";eval(%s)" % json.dumps(src))

        if srcName == "modjewel-require.js":
            lines.append("require('modjewel').warnOnRecursiveRequire(true);")
            if not useEval:
                lines.append("")

    lines.append("// require('weinre/common/Weinre').showNotImplemented();")
    lines.append("require('weinre/target/Target').main()")
    lines.append("})();")
    targetScript = "\n".join(lines)

    with open(oFileName, "w") as oFile:
        oFile.write(targetScript)

    log("generated: %s" % oFileName)

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
