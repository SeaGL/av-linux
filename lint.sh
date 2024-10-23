#!/bin/bash

set -euo pipefail

trap 'echo Failed!' ERR

# See 8f01ed1063e61407dc71f01863b0256f5082fd94 for rationale
echo 'Checking that all `flatpak` invocations pass `--noninteractive --system`.'
# We use () to make this a subshell to avoid ! not triggering a `set -e` bailout; see bash(1)'s documentation on this flag for more
( ! grep -rn --exclude-dir=.git flatpak | grep -ve systemctl -e /var/lib/flatpak -e 'remote-add.*--system' -e flathub.flatpakrepo | grep -v -- '--noninteractive --system')

for i in bin/* sbin/*; do
	echo 'Checking that `'"$i"'` contains `set -euo pipefail`.'
	grep -q 'set -euo pipefail' $i
done
