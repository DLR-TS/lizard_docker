#!/usr/bin/env bash

function echoerr { echo "$@" >&2; exit 1;}
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

set -o pipefail

cd /tmp/lizard
lizard \
        --exclude "*/.local/*" \
        --exclude "*/build/*" \
        --exclude "*/cmake/*" \
        --exclude "*/external/*" \
        --exclude "*/install/*" \
        ; \
lizard \
        --exclude "*/.local/*" \
        --exclude "*/build/*" \
        --exclude "*/cmake/*" \
        --exclude "*/external/*" \
        --exclude "*/install/*" \
        --output_file=lizard_report.xml -X;

