#!/bin/sh
CWD=`dirname $0`
WEINRE=`dirname $CWD`
CP=$WEINRE/weinre.server/bin:$WEINRE/weinre.build/out:$WEINRE/weinre.build/vendor/cli/commons-cli.jar:$WEINRE/weinre.build/vendor/jetty/jetty.jar:$WEINRE/weinre.build/vendor/json4j/json4j.jar:$WEINRE/weinre.build/vendor/jetty/servlet-api.jar
PORT=8096
DEBUG=jdwp=transport=dt_socket,server=y,suspend=n,address=localhost:$PORT

java \
	-agentlib:$DEBUG \
	-Dfile.encoding=UTF-8 \
	-classpath $CP \
	weinre.server.Main