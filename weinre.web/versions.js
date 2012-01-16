/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

 if (typeof Weinre == "undefined") Weinre = {};

 Weinre.Versions = {
    weinre:   "@WEINRE_VERSION@",
    build:    "@BUILD_NUMBER_DATE@",
    jetty:    "@JETTY_VERSION@",
    servlet:  "@JAVAX_SERVLET_VERSION@-@JAVAX_SERVLET_VERSION_IMPL@",
    webkit:   "@WEBKIT_VERSION@",
    cli:      "@CLI_VERSION@",
    json4j:   "@JSON4J_VERSION@",
    json2:    "@JSON2_VERSION@",
    swt:      "@SWT_VERSION@",
    modjewel: "@MODJEWEL_VERSION@"
 };
