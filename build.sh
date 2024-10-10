#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

flatpak remote-add --system flathub --from /tmp/flathub.flatpakrepo

# Streaming machine packages
rpm-ostree install obs-studio mpv yt-dlp zenity
# Presentation machine packages
rpm-ostree install libreoffice
flatpak install --noninteractive --system im.riot.Riot com.nextcloud.desktopclient.nextcloud

### Configure system

sed -i 's/\[daemon\]/[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=seagloperator/' /usr/etc/gdm/custom.conf
systemctl enable seagl-reset-users.service

cat > /usr/etc/sudoers.d/10-unconditionally-grant-sudoers <<EOF
# Don't bother laptop users with needing to know passwords:
# rooms with laptops are physically secured by UW staff when
# unattended at the venue.
ALL            ALL = (ALL) NOPASSWD: ALL
EOF

# https://askubuntu.com/q/1037553/49090, https://askubuntu.com/q/1014965/49090, dconf(7)
cat > /usr/etc/dconf/db/local.d/00-suppress-autosuspend <<EOF
[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
EOF

dconf update

# TODO set up Nextcloud, and make sure its data dir is not in ~
# TODO set up OBS
