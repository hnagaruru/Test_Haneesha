#!/bin/sh
#
# Adjust classpath for Java version and run the tool...
#

source $_G_ROOT_DIR/bin/checkjava.sh

# Java 8 or 11 is required
JAVA_VERSION=$(verify_and_get_java_version)

if [ -n "$_DEBUG" ]; then
  echo Using Java $JAVA_VERSION
fi

AllJars="$AllJars:$_G_ROOT_DIR/lib/java${JAVA_VERSION}/*"
if [ "$JAVA_VERSION" = "8" ]; then
  AllJars="$AllJars:$JAVA_HOME/lib/tools.jar"
fi

CMD="exec \"$_JAVACMD\" $_DEBUG $GOSU_OPTS -classpath \"$AllJars\" gw.lang.Gosu"
