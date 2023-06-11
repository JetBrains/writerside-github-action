#!/bin/bash

set -e
export DISPLAY=:99
Xvfb :99 &
/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product $PRODUCT --runner github -output-dir artifacts/ || true
echo "Test existing of $ARTIFACT artifact"
test -e artifacts/$ARTIFACT