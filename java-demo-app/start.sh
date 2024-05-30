#!/bin/sh

java $JAVA_OPTS -javaagent:/jmx_prometheus_javaagent-0.20.0.jar=8088:/prometheus-jmx-config.yaml -jar UniversityHttpServer.jar $OBJ_SIZE