#!/bin/sh

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

