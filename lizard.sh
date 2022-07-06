#!/usr/bin/env bash

function echoerr { echo "$@" >&2; exit 1;}
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

set -o pipefail
lizard --exclud "*/.local/*" --exclude "*/build/*"; \
lizard --exclud "*/.local/*" --exclude "*/build/*" --output_file=lizard_report.xml -X; \
cp lizard_report.xml /tmp/out 