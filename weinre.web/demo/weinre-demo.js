/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright (c) 2011 IBM Corporation
 */

//------------------------------------------------------------------------------
var started = false

var buttonStartStuff
var buttonClearOutput
var buttonErrorDOMEvent
var buttonErrorWindowEvent
var buttonErrorXHREvent
var buttonErrorSetTimeout
var buttonErrorSetInterval
var outputElement
var storageIndex = 0
var db
var otherDB

// set the id based on the hash
var hash = location.href.split("#")[1]
if (!hash) hash = "anonymous"
window.WeinreServerId = hash

//------------------------------------------------------------------------------
function onLoad() {
    if (!buttonStartStuff)       buttonStartStuff       = document.getElementById("button-start-stuff")
    if (!buttonClearOutput)      buttonClearOutput      = document.getElementById("button-clear-output")
    if (!buttonErrorDOMEvent)    buttonErrorDOMEvent    = document.getElementById("button-error-DOM-event")
    if (!buttonErrorWindowEvent) buttonErrorWindowEvent = document.getElementById("button-error-window-event")
    if (!buttonErrorXHREvent)    buttonErrorXHREvent    = document.getElementById("button-error-XHR-event")
    if (!buttonErrorSetTimeout)  buttonErrorSetTimeout  = document.getElementById("button-error-setTimeout")
    if (!buttonErrorSetInterval) buttonErrorSetInterval = document.getElementById("button-error-setInterval")
    if (!outputElement)          outputElement          = document.getElementById("output")

    buttonStartStuff.addEventListener("click", function() {
        lastClickTime = new Date().toString()
        if (db) db.transaction(addClick)

        openTheOtherDatabase()

        if (!started) {
            buttonStartStuff.value = "stop stuff"
            startStuff()
        }
        else {
            buttonStartStuff.value = "start stuff"
            stopStuff()
        }
        started = !started
    })

    buttonErrorDOMEvent.addEventListener("click", function buttonClicked() {
        willThrowError()
    })

    buttonErrorWindowEvent.addEventListener("click", function() {
        var event = document.createEvent("Events")
        event.initEvent("demo", true, true)
        window.dispatchEvent(event)
    })

    window.addEventListener("demo", willThrowError)

    buttonErrorXHREvent.addEventListener("click", function() {
        var xhr = new XMLHttpRequest()
        xhr.addEventListener("readystatechange", willThrowError)
        xhr.open("GET", "something.that.doesn't.exist")
        xhr.send()
    })

    buttonErrorSetTimeout.addEventListener("click", function() {
        setTimeout(willThrowError, 1000)
    })

    buttonErrorSetInterval.addEventListener("click", function() {
        var intervalID

        setTimeout(function() {clearInterval(intervalID)}, 3000)

        intervalID = setInterval(willThrowError, 1000)
    })

    buttonClearOutput.addEventListener("click", function() {
        outputElement.innerHTML = ""
    })

    openTheDatabase()
}

//------------------------------------------------------------------------------
function willThrowError() {
    throwsError()
}

function throwsError() {
    x = null
    x.doSomething()
}

//------------------------------------------------------------------------------
var interval

function startStuff() {
    if (window.localStorage)   window.localStorage.clear()
    if (window.sessionStorage) window.sessionStorage.clear()

    storageIndex = 0

    interval = setInterval(intervalStuff, 1000)
}

function stopStuff() {
    clearInterval(interval)
}

//------------------------------------------------------------------------------
function intervalStuff() {

    var message = "doing interval stuff at " + new Date()

    // add a timeout
    setTimeout(function() { console.log(message)}, 333)

    // add a timeline marker
    console.markTimeline(message)

    // write to local- and sessionStorage
    if (window.localStorage) {
        var smessage = message + " (local)"
        window.localStorage.setItem(  "item-" + storageIndex, smessage)
    }

    if (window.sessionStorage) {
        var smessage = message + " (session)"
        window.sessionStorage.setItem("item-" + storageIndex, smessage)
    }
    storageIndex++

    // write the message to the page
    output(message)

    // do an XHR
    var xhr = new XMLHttpRequest()
    // xhr.addEventListener("readystatechange", function() {logXhr(this)})
    xhr.open("GET", "../target/target-script.js", true)
    xhr.send()
}

//------------------------------------------------------------------------------
function sqlSuccess(tx, resultSet) {
    console.log("SQL Success!")
}

//------------------------------------------------------------------------------
function sqlError(tx, error) {
    console.log("SQL Error " + error.code + ": " + error.message)
}

//------------------------------------------------------------------------------
var lastClickTime

function addClick(tx) {
    var sql = "insert into clicks (date) values (?)"
    tx.executeSql(sql, [lastClickTime], null, sqlError)
}

//------------------------------------------------------------------------------
function clearDatabase(tx, resultSet) {
    var sql = "delete from clicks"
    tx.executeSql(sql, null, null, sqlError);
}

//------------------------------------------------------------------------------
function createDatabase(tx) {
    var schema = "clicks (id integer primary key, date text)"
    var sql = "create table if not exists " + schema

    tx.executeSql(sql, null, clearDatabase, sqlError);
}

//------------------------------------------------------------------------------
function createDatabase_other(tx) {
    var schema = "clicks_other (id integer primary key, other text)"
    var sql = "create table if not exists " + schema

    tx.executeSql(sql, null, null, sqlError);
}

//------------------------------------------------------------------------------
function openTheDatabase() {
    if (window.openDatabase) {
        db = window.openDatabase("clicks_db", "1.0", "clicks_db", 8192)
        db.transaction(createDatabase)
    }
}

//------------------------------------------------------------------------------
function openTheOtherDatabase() {
    if (otherDB) return

    if (window.openDatabase) {
        otherDB = window.openDatabase("clicks_other_db", "1.0", "clicks_other_db", 8192)
        otherDB.transaction(createDatabase_other)
    }
}

//------------------------------------------------------------------------------
function output(string) {
    var element = document.createElement("div")
    element.innerHTML = string
    outputElement.appendChild(element)
}

//------------------------------------------------------------------------------
function logXhr(xhr) {
    console.log("xhr: readyState: " + xhr.readyState)
}

