
#---------------------------------------------------------------------------------
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
#---------------------------------------------------------------------------------

HookLib = require('../common/HookLib')

#-------------------------------------------------------------------------------
module.exports = class HookSites

#---------------------------------------------------------------------------
HookSites.window_clearInterval            = HookLib.addHookSite window, "clearInterval"
HookSites.window_clearTimeout             = HookLib.addHookSite window, "clearTimeout"
HookSites.window_setInterval              = HookLib.addHookSite window, "setInterval"
HookSites.window_setTimeout               = HookLib.addHookSite window, "setTimeout"
HookSites.window_addEventListener         = HookLib.addHookSite window, "addEventListener"
HookSites.Node_addEventListener           = HookLib.addHookSite Node.prototype, "addEventListener"
HookSites.XMLHttpRequest_open             = HookLib.addHookSite XMLHttpRequest.prototype, "open"
HookSites.XMLHttpRequest_send             = HookLib.addHookSite XMLHttpRequest.prototype, "send"
HookSites.XMLHttpRequest_addEventListener = HookLib.addHookSite XMLHttpRequest.prototype, "addEventListener"

if window.openDatabase
    HookSites.window_openDatabase = HookLib.addHookSite window, "openDatabase"

if window.localStorage
    HookSites.LocalStorage_setItem    = HookLib.addHookSite window.localStorage, "setItem"
    HookSites.LocalStorage_removeItem = HookLib.addHookSite window.localStorage, "removeItem"
    HookSites.LocalStorage_clear      = HookLib.addHookSite window.localStorage, "clear"

if window.sessionStorage
    HookSites.SessionStorage_setItem    = HookLib.addHookSite window.sessionStorage, "setItem"
    HookSites.SessionStorage_removeItem = HookLib.addHookSite window.sessionStorage, "removeItem"
    HookSites.SessionStorage_clear      = HookLib.addHookSite window.sessionStorage, "clear"

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
