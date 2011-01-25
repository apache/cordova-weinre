/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2010, 2011 IBM Corporation
 */

//-----------------------------------------------------------------------------
function main() {
//    window.addEventListener("load", addClickToExpandImageHandlers, false);
}

//-----------------------------------------------------------------------------
function addClickToExpandImageHandlers() {
    var elements = document.getElementsByTagName("img")
    for (var i=0; i<elements.length; i++) {
        var element = elements[i]
        if (!hasClass(element, "expand-on-click")) continue
     
        addClass(element, "width-transition")
        element._original_width_ = element.width 
        element._contracted_     = true
        element.width            = element.width / 2
        
        element.addEventListener("click", clickToExpand, false)
    }
}

//-----------------------------------------------------------------------------
function clickToExpand(event) {
    var element = this
    
    if (element._contracted_) {
        element.width = element._original_width_
    }
    else {
        element.width = element._original_width_ / 2
    }
    
    element._contracted_ = ! element._contracted_
    
//     if (hasClass(element, "contracted")) {
//         removeClass(element, "contracted")
//     }
//     
//     else {
//         addClass(element,    "contracted")
//     }
}

//-----------------------------------------------------------------------------
function hasClass(element, className) {
    var classNames = element.className.split(/\s+/)
    for (var i=0; i<classNames.length; i++) {
        if (className == classNames[i]) return true
    }
    return false
}

//-----------------------------------------------------------------------------
function addClass(element, className) {
    if (hasClass(element, className)) return
    
    element.className += " " + className
}

//-----------------------------------------------------------------------------
function removeClass(element, className) {
    var classNames = element.className.split(/\s+/)
    for (var i=0; i<classNames.length; i++) {
        if (className == classNames[i]) {
            classNames[i] = ""
        }
    }
    element.className = classNames.join(" ")
}

//-----------------------------------------------------------------------------
main()
