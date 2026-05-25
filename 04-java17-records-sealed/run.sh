#!/bin/bash
# Stage 04 requires Java 21 for sealed interfaces + record patterns in switch.
JAVA21=/usr/lib/jvm/jdk-21.0.11-oracle-x64/bin
$JAVA21/javac *.java && $JAVA21/java Demo
