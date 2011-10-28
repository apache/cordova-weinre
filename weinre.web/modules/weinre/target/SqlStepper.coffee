
#---------------------------------------------------------------------------------
# weinre is available under *either* the terms of the modified BSD license *or* the
# MIT License (2008). See http:#opensource.org/licenses/alphabetical for full text.
#
# Copyright (c) 2010, 2011 IBM Corporation
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
