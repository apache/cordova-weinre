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

//------------------------------------------------------------------------------
function onLoad() {
    if (!buttonStartStuff)  buttonStartStuff  = document.getElementById("button-start-stuff")
    if (!buttonClearOutput) buttonClearOutput = document.getElementById("button-clear-output")
    if (!outputElement)     outputElement     = document.getElementById("output")
    
    buttonStartStuff.addEventListener("click", function() {
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
    
}

//------------------------------------------------------------------------------
var interval

function startStuff() {
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
function output(string) {
    var element = document.createElement("div")
    element.innerHTML = string
    outputElement.appendChild(element)
}

//------------------------------------------------------------------------------
function logXhr(xhr) {
    console.log("xhr: readyState: " + xhr.readyState)
}

