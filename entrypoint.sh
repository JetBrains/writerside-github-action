#!/bin/bash

set -e
/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product $PRODUCT -output-dir artifacts/ || true
echo "Test existing of $ARTIFACT artifact"
test -e artifacts/$ARTIFACT