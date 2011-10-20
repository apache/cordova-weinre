#!/bin/sh

# ---
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
# 
# Copyright (c) 2010, 2011 IBM Corporation
# ---

#-------------------------------------------------------------
# create a link to your workspace first!
#-------------------------------------------------------------
EWS=~/weinre-workspace

cd $EWS/weinre.build

#-------------------------------------------------------------
# run-when-changed: https://gist.github.com/240922
#-------------------------------------------------------------

run-when-changed "ant build" \
  ../weinre.application \
  ../weinre.build/*.xml \
  ../weinre.build/*.properties \
  ../weinre.build/scripts \
  ../weinre.doc \
  ../weinre.server \
  ../weinre.web
  
