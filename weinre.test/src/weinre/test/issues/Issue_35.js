#!/usr/bin/env node

var util = require("util")
var data = ""

process.stdin.setEncoding('utf8')

process.stdin.on('data', function (chunk) {
    data = data + chunk
    console.log("\nread: " + chunk + " (len: " + chunk.length + ")")
})

process.stdin.on('end', function () {
    console.log("\ndone: " + data)
    data = eval(data)
    var object = JSON.parse(data)
    var redo = JSON.stringify(object)
    console.log("\nredo: " + redo + " (len: " + redo.length + ")")
    var redo = JSON.stringify(redo)
    console.log("\nredo: " + redo + " (len: " + redo.length + ")")
    var redo = JSON.stringify(redo)
    console.log("\nredo: " + redo + " (len: " + redo.length + ")")
    console.log("\ndump:")
    console.log(util.inspect(object,true,null))
})

process.stdin.resume()
