#!/bin/bash
set -e
echo "Running: Execute idea.sh"
/opt/builder/bin/idea.sh helpbuilderinspect -source-dir . -product $PRODUCT --runner github -output-dir artifacts/ || true
echo "Running: Test existing artifact '$ARTIFACT'"
test -e artifacts/$ARTIFACT