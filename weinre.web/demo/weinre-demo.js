/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2011 IBM Corporation
 */

//------------------------------------------------------------------------------
var started = false
var button

//------------------------------------------------------------------------------
function onLoad() {
    if (!button) button = document.getElementById("button")
    
    button.addEventListener("click", function() {
        if (!started) {
            button.value = "stop stuff"
            startStuff()
        }
        else {
            button.value = "start stuff"
            stopStuff()      
        }
        started = !started
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
    // add a timeout
    setTimeout(function() { console.log("doing interval stuff")}, 333)
    
    // add a timeline marker
    console.markTimeline("doing interval Stuff")
    
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
function logXhr(xhr) {
    console.log("xhr: readyState: " + xhr.readyState)
}

