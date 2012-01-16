
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

Weinre      = require('../common/Weinre')
IDGenerator = require('../common/IDGenerator')
HookSites   = require('./HookSites')
SqlStepper  = require('./SqlStepper')

id2db   = {}
name2db = {}

#-------------------------------------------------------------------------------
module.exports = class WiDatabaseImpl

    constructor: ->
        return unless window.openDatabase

        HookSites.window_openDatabase.addHooks
            after: (receiver, args, db) ->
                return if not db

                name    = args[0]
                version = args[1]

                dbAdd db, name, version

    #---------------------------------------------------------------------------
    @getDatabases: ->
        result = []
        for id of id2db
            result.push id2db[id]
        result

    #---------------------------------------------------------------------------
    getDatabaseTableNames: (databaseId, callback) ->
        db = dbById(databaseId)
        return unless db

        stepper = SqlStepper([ getTableNames_step_1, getTableNames_step_2 ])
        stepper.callback = callback
        stepper.run db, logSqlError

    #---------------------------------------------------------------------------
    executeSQL: (databaseId, query, callback) ->
        db = dbById(databaseId)
        return unless db

        txid = Weinre.targetDescription.channel + "-" + IDGenerator.next()

        stepper = SqlStepper([ executeSQL_step_1, executeSQL_step_2 ])
        stepper.txid     = txid
        stepper.query    = query
        stepper.callback = callback

        stepper.run db, executeSQL_error

        if callback
            Weinre.WeinreTargetCommands.sendClientCallback callback, [ true, txid ]

#-------------------------------------------------------------------------------
logSqlError = (sqlError) ->
      console.log "SQL Error #{sqlError.code}: " + sqlError.message

#-------------------------------------------------------------------------------
getTableNames_step_1 = () ->
      @executeSql "SELECT name FROM sqlite_master WHERE type='table'"

#-------------------------------------------------------------------------------
getTableNames_step_2 = (resultSet) ->
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

      Weinre.WeinreTargetCommands.sendClientCallback @callback, [ result ]

#-------------------------------------------------------------------------------
executeSQL_step_1 = () ->
      @executeSql @query

#-------------------------------------------------------------------------------
executeSQL_step_2 = (resultSet) ->
      columnNames = []
      values = []
      rows = resultSet.rows
      i = 0

      while i < rows.length
          row = rows.item(i)
          if i == 0
              for propName of row
                  columnNames.push propName
          j = 0

          while j < columnNames.length
              values.push row[columnNames[j]]
              j++
          i++

      Weinre.wi.DatabaseNotify.sqlTransactionSucceeded @txid, columnNames, values

#-------------------------------------------------------------------------------
executeSQL_error = (sqlError) ->
      error =
          code: sqlError.code
          message: sqlError.message

      Weinre.wi.DatabaseNotify.sqlTransactionFailed @txid, error

#-------------------------------------------------------------------------------
dbById = (id) ->
      record = id2db[id]
      return null unless record
      record.db

#-------------------------------------------------------------------------------
dbRecordById = (id) ->
      id2db[id]

#-------------------------------------------------------------------------------
dbRecordByName = (name) ->
      name2db[name]

#-------------------------------------------------------------------------------
dbAdd = (db, name, version) ->
      record = dbRecordByName(name)
      return record if record

      record = {}
      record.id      = IDGenerator.next()
      record.domain  = window.location.origin
      record.name    = name
      record.version = version
      record.db      = db

      id2db[record.id] = record
      name2db[name] = record

      payload = {}
      payload.id      = record.id
      payload.domain  = record.domain
      payload.name    = name
      payload.version = version
      Weinre.WeinreExtraTargetEvents.databaseOpened payload

#-------------------------------------------------------------------------------
require("../common/MethodNamer").setNamesForClass(module.exports)
