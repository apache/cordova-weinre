/*
 * weinre is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright (c) 2010, 2011 IBM Corporation
 */

var weinre_protocol = location.protocol
var weinre_host     = location.hostname
var weinre_port     = location.port
var weinre_pathname = location.pathname
var weinre_id       = "anonymous"

var hash = location.href.split("#")[1]
if (hash) {
    weinre_id = hash
}

replaceURL("url-client-ui",              buildHttpURL("client/#" + weinre_id))
replaceURL("url-interfaces",             buildHttpURL("interfaces/interfaces.html"))
replaceURL("url-target-demo",            buildHttpURL("demo/weinre-demo.html#" + weinre_id))
replaceURL("url-target-demo-min",        buildHttpURL("demo/weinre-demo-min.html#" + weinre_id))
replaceURL("url-target-script",          buildHttpURL("target/target-script-min.js#" + weinre_id))
replaceURL("url-target-bookmarklet",     getTargetBookmarklet(), "weinre target debug")
replaceURL("url-target-documentation",   buildHttpURL("doc/"))
//replaceURL("url-client-protocol",        buildHttpURL("ws/client/"))
//replaceURL("url-target-protocol",        buildHttpURL("ws/target/"))

replaceText("version-weinre",    Weinre.Versions.weinre)
replaceText("version-build",     Weinre.Versions.build)
replaceText("version-webkit",    Weinre.Versions.webkit)
replaceText("version-jetty",     Weinre.Versions.jetty)
replaceText("version-servlet",   Weinre.Versions.servlet)
replaceText("version-cli",       Weinre.Versions.cli)
replaceText("version-json4j",    Weinre.Versions.json4j)
replaceText("version-json2",     Weinre.Versions.json2)
replaceText("version-swt",       Weinre.Versions.swt)
replaceText("version-modjewel",  Weinre.Versions.modjewel)

replaceText("target-bookmarklet-src-pre",       getTargetBookmarklet())
replaceText("target-bookmarklet-src-text-area", getTargetBookmarklet())

replaceText("url-target-script-raw",  buildHttpURL("target/target-script-min.js#" + weinre_id))

//---------------------------------------------------------------------
function buildHttpURL(uri) {
    var port     = weinre_port
    var pathname = weinre_pathname

    if (pathname == "/index.html") pathname = "/"

    if (weinre_protocol == "file:") {
        return uri
    }

    else if (weinre_protocol == "http:") {
        if (port != "") port = ":" + port

        return weinre_protocol + "//" + weinre_host + port + pathname + uri
    }

    else if (protocol == "https:") {
        if (port != "") port = ":" + port

        return weinre_protocol + "//" + weinre_host + port + pathname + uri
    }
}

//-----------------------------------------------------------------------------
function targetBookmarkletFunction(e){
    e.setAttribute("src","???");
    document.getElementsByTagName("body")[0].appendChild(e);
}

//-----------------------------------------------------------------------------
function getTargetBookmarklet() {
    var script = targetBookmarkletFunction.toString();
    script = script.replace(/\n/g,   "")
    script = script.replace("targetBookmarkletFunction","")
    script = script.replace(/\s*/g, "")
    script = script.replace("???", buildHttpURL("target/target-script-min.js#" + weinre_id))
    script = "(" + script + ')(document.createElement("script"));void(0);'
    return 'javascript:' + script
}

//---------------------------------------------------------------------
function replaceURL(id, url, linkText) {
    if (!linkText) linkText = url
    replaceText(id, "<a href='" + url + "'>" + linkText + "</a>");
}

//---------------------------------------------------------------------
function replaceText(id, text) {
    var element = document.getElementById(id)
    if (null == element) {
//      alert("error: can't find element with id '" + id + "'")
        return
    }

    element.innerHTML = text
}
