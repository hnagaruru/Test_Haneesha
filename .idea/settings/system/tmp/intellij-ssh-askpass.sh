#!/bin/sh
"C:/GW/studio/sdk/jre/jre-win/bin/java" -cp "C:/GW/studio/sdk/plugins/git4idea/lib/git4idea-rt.jar;C:/GW/studio/sdk/lib/xmlrpc-2.0.1.jar;C:/GW/studio/sdk/lib/commons-codec-1.13.jar;C:/GW/studio/sdk/lib/util.jar" org.jetbrains.git4idea.nativessh.GitNativeSshAskPassApp "$@"
