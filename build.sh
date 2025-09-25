#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages

flatpak install --noninteractive --system com.obsproject.Studio # This MUST be from Flathub and not Fedora repos to have OpenH264 support
flatpak install --noninteractive --system com.obsproject.Studio.Plugin.SceneSwitcher
flatpak install --noninteractive --system com.obsproject.Studio.Plugin.SourceRecord
flatpak install --noninteractive --system im.riot.Riot
flatpak install --noninteractive --system org.pulseaudio.pavucontrol

systemctl enable seagl-init-system-flatpak.service
mv /var/lib/flatpak /usr/lib/seagl-flatpak

### Configure system

systemctl set-default graphical.target
systemd-firstboot --locale="en_US.UTF-8" --timezone=America/Los_Angeles --hostname seagl-unconfigured --root-password=password

sed -i 's/\[daemon\]/[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=seagloperator/' /etc/gdm/custom.conf
systemctl enable seagl-reset-users.service

ln -s /usr/share/applications/room-setup.desktop /etc/xdg/autostart

cat > /etc/dconf/db/local.d/00-disable-gnome-tour <<EOF
[org/gnome/shell]
welcome-dialog-last-shown-version='$(rpm -qv gnome-shell | cut -d- -f3)'
EOF

dconf update
# TODO figure out why this hack is needed
systemctl enable seagl-dconf-update-hack.service

# Put some useful stuff in bash history so ^R muscle memory works (AJ relies on this a lot)
cat > /etc/skel/.bash_history <<EOF
$(ls /usr/bin/seagl* | xargs -n 1 basename)
$(ls /usr/sbin/seagl* | xargs -n 1 basename)
sudo rpm-ostree update
EOF
