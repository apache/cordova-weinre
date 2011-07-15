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
var outputElement 
var storageIndex = 0
var db

// set the id based on the hash
var hash = location.href.split("#")[1]
if (!hash) hash = "anonymous"
window.WeinreServerId = hash

//------------------------------------------------------------------------------
function onLoad() {
    if (!buttonStartStuff)  buttonStartStuff  = document.getElementById("button-start-stuff")
    if (!buttonClearOutput) buttonClearOutput = document.getElementById("button-clear-output")
    if (!outputElement)     outputElement     = document.getElementById("output")
    
    buttonStartStuff.addEventListener("click", function() {
        lastClickTime = new Date().toString()
        if (db) db.transaction(addClick)
        
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
    
    buttonClearOutput.addEventListener("click", function() {
        outputElement.innerHTML = ""
    })
    
    setTimeout(_openDatabase,1000)
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
    
    // cause an error
    var empty = null
    empty.x = 1
    
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
function _openDatabase() {
    if (window.openDatabase) {
        db = window.openDatabase("clicks", "1.0", "clicks", 8192)
        db.transaction(createDatabase)
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

