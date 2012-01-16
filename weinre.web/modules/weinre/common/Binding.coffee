
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

Ex = require('./Ex')

#-------------------------------------------------------------------------------
module.exports = class Binding

    constructor: (receiver, method) ->
        if not receiver
            throw new Ex(arguments, "receiver argument for Binding constructor was null")

        method = receiver[method] if typeof (method) == "string"

        if typeof (method) is not "function"
            throw new Ex(arguments, "method argument didn't specify a function")

        return -> method.apply(receiver, [].slice.call(arguments))

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
