/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

// open "http://search.npmjs.org/#/grunt" ; sudo npm -g install grunt

var child_process = require("child_process")

//------------------------------------------------------------------------------
// list of source files to watch
//------------------------------------------------------------------------------
var sourceFiles = [
    "grunt.js",
    
    "weinre.build/*.sh", 
    "weinre.build/*.properties", 
    "weinre.build/*.xml", 
    "weinre.build/*.template", 
    "weinre.build/scripts/**/*", 
    
    "weinre.doc/**/*",
    
    "weinre.server/interfaces/**/*",
    "weinre.server/lib/**/*",
    "weinre.server/package.json",
    "weinre.server/README.md",

    "weinre.web/**/*"
]

//------------------------------------------------------------------------------
var gruntConfig = {
    watch: {
        make: {
            files: sourceFiles,
            tasks: ["runAnt"]
        }
    }
}

//------------------------------------------------------------------------------
module.exports = function(grunt) {
    grunt.initConfig(gruntConfig)
    
    grunt.registerTask("default", "watch")
    grunt.registerTask("runAnt", "run ant", function(){task_runAnt(this, grunt)})
}

//------------------------------------------------------------------------------
// run "make"
//------------------------------------------------------------------------------
function task_runAnt(task, grunt) {
    var done = task.async()
    var make = child_process.spawn('ant', ['-f', 'weinre.build/build.xml'])
    
    make.stdout.on("data", function(data) {
        grunt.log.write("" + data)
    })
    
    make.stderr.on("data", function(data) {
        grunt.log.error("" + data)
    })
    
    make.on("exit", function(code) {
        if (code === 0) return done(true)
        
        grunt.log.writeln("error running ant", code)
        return done(false)
    })
}

