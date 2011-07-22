#/bin/sh

# ---
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
# 
# Copyright (c) 2011 IBM Corporation
# ---

git log "--pretty=format:- %s" $1.. | \
    sed 's/#\([0-9]*\)/\<a href="https:\/\/github.com\/phonegap\/weinre\/issues\/1"\>issue \1\<\/a\>./' |
    sed 's/^-/\<li\>/'

#    sed 's/#\([0-9]*\)/[issue \1](https:\/\/github.com\/pmuellr\/weinre\/issues\/1)./'
