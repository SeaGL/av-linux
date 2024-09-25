#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

flatpak remote-add --system flathub --from /tmp/flathub.flatpakrepo

# Streaming packages
rpm-ostree install obs-studio mpv yt-dlp
# Presentation machine packages
rpm-ostree install libreoffice
flatpak install --noninteractive --system im.riot.Riot

#### Example for enabling a System Unit File

#systemctl enable podman.socket
