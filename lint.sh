#!/bin/bash

set -euo pipefail

trap 'echo Failed!' ERR

# See 8f01ed1063e61407dc71f01863b0256f5082fd94 for rationale
echo 'Checking that all `flatpak` invocations pass `--system`.'
# We use () to make this a subshell to avoid ! not triggering a `set -e` bailout; see bash(1)'s documentation on this flag for more
( ! grep -n flatpak *.sh | grep -v -- --system )
