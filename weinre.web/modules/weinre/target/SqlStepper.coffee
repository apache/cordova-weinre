
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

Binding = require('../common/Binding')

#-------------------------------------------------------------------------------
module.exports = class SqlStepper

    constructor: (steps) ->
        return new SqlStepper(steps) unless (this instanceof SqlStepper)

        @__context = {}

        context = @__context
        context.steps = steps

    #---------------------------------------------------------------------------
    run: (db, errorCallback) ->
        context = @__context
        if context.hasBeenRun
            throw new Ex(arguments, "stepper has already been run")

        context.hasBeenRun       = true
        context.db               = db
        context.errorCallback    = errorCallback
        context.nextStep         = 0
        context.ourErrorCallback = new Binding(this, ourErrorCallback)
        context.runStep          = new Binding(this, runStep)

        @executeSql = new Binding(this, executeSql)

        db.transaction context.runStep

    #---------------------------------------------------------------------------
    @example: (db, id) ->
        step1 = ->
            @executeSql "SELECT name FROM sqlite_master WHERE type='table'"

        step2 = (resultSet) ->
            rows = resultSet.rows
            result = []

            i = 0
            while i < rows.length
                name = rows.item(i).name
                if name == "__WebKitDatabaseInfoTable__"
                    i++
                    continue

                result.push name
                i++

            console.log "[#{@id}] table names: " + result.join(", ")

        errorCb = (sqlError) ->
            console.log "[#{@id}] sql error:#{sqlError.code}: " + sqlError.message

        stepper = new SqlStepper([ step1, step2 ])
        stepper.id = id
        stepper.run db, errorCb


#-------------------------------------------------------------------------------
executeSql = (statement, data) ->
      context = @__context
      context.tx.executeSql statement, data, context.runStep, context.ourErrorCallback

#-------------------------------------------------------------------------------
ourErrorCallback = (tx, sqlError) ->
      context = @__context
      context.errorCallback.call this, sqlError

#-------------------------------------------------------------------------------
runStep = (tx, resultSet) ->
      context = @__context
      return if context.nextStep >= context.steps.length

      context.tx = tx
      context.currentStep = context.nextStep
      context.nextStep++

      step = context.steps[context.currentStep]
      step.call this, resultSet

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
