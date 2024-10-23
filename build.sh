#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

/tmp/osrelease.sh

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

flatpak remote-add --system flathub --from /tmp/flathub.flatpakrepo

# General system packages
rpm-ostree install jq age seahorse
# Streaming machine packages
rpm-ostree install mpv yt-dlp zenity
flatpak install --noninteractive --system com.obsproject.Studio # This MUST be from Flathub and not Fedora repos to have OpenH264 support
flatpak install --noninteractive --system im.riot.Riot
# Presentation machine packages
rpm-ostree install libreoffice nextcloud-client nextcloud-client-nautilus

systemctl enable seagl-init-system-flatpak.service
mv /var/lib/flatpak /usr/lib/seagl-flatpak

### Configure system

systemctl set-default graphical.target
systemd-firstboot --locale="en_US.UTF-8" --timezone=America/Los_Angeles --hostname seagl-unconfigured --root-password=password

sed -i 's/\[daemon\]/[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=seagloperator/' /etc/gdm/custom.conf
systemctl enable seagl-reset-users.service

ln -s /usr/share/applications/room-setup.desktop /etc/xdg/autostart

cat > /etc/sudoers.d/10-unconditionally-grant-sudoers <<EOF
# Don't bother laptop users with needing to know passwords:
# rooms with laptops are physically secured by UW staff when
# unattended at the venue.
ALL            ALL = (ALL) NOPASSWD: ALL
EOF

cat > /etc/polkit-1/rules.d/00-allow-everything.rules <<EOF
// Don't bother laptop users with needing to know passwords:
// rooms with laptops are physically secured by UW staff when
// unattended at the venue.
polkit.addRule(function(action, subject) {
    return polkit.Result.YES;
});
EOF

# https://askubuntu.com/q/1037553/49090, https://askubuntu.com/q/1014965/49090, dconf(7)
cat > /etc/dconf/db/local.d/00-suppress-autosuspend <<EOF
[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'

[org/gnome/desktop/session]
idle-delay=300
EOF

cat > /etc/dconf/db/local.d/00-disable-screen-lock <<EOF
[org/gnome/desktop/screensaver]
lock-enabled=false

[org/gnome/desktop/lockdown]
disable-lock-screen=true
EOF

# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/desktop_migration_and_administration_guide/extensions-enable
mkdir -p /usr/share/gnome-shell/extensions/{appmenu-is-back@fthx,grand-theft-focus@zalckos.github.com}
cd /usr/share/gnome-shell/extensions/appmenu-is-back@fthx
unzip /tmp/appmenu-is-backfthx.v3.shell-extension.zip
cd /usr/share/gnome-shell/extensions/grand-theft-focus@zalckos.github.com
unzip /tmp/grand-theft-focuszalckos.github.com.v7.shell-extension.zip
chmod 644 /usr/share/gnome-shell/extensions/*/*
cat > /etc/dconf/db/local.d/00-gnome-shell-extensions <<EOF
[org/gnome/shell]
enabled-extensions=['grand-theft-focus@zalckos.github.com', 'appmenu-is-back@fthx', 'places-menu@gnome-shell-extensions.gcampax.github.com', 'window-list@gnome-shell-extensions.gcampax.github.com']
EOF

cat > /etc/dconf/db/local.d/00-disable-gnome-shell-animations <<EOF
[org/gnome/desktop/interface]
enable-animations=false
EOF

cat > /etc/dconf/db/local.d/00-set-gnome-shell-dock <<EOF
[org/gnome/shell]
# This is for presentation laptops. Streaming laptops override this at runtime during room setup.
# TODO add SeaGL-specific scripts into here
favorite-apps=['org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Software.desktop', 'org.libreoffice.LibreOffice.impress.desktop', 'com.nextcloud.desktopclient.nextcloud.desktop']
EOF

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

mkdir -p /etc/firefox/policies
cat > /etc/firefox/policies/policies.json <<EOF
{
	"policies": {
		"Bookmarks": [
			{
				"Title": "Attend Portal",
				"URL": "https://attend.seagl.org/",
				"Placement": "toolbar"
			},
			{
				"Title": "A/V test results",
				"URL": "AV_TEST_RESULTS_PLACEHOLDER",
				"Placement": "toolbar"
			}
		],
		"DisableFirefoxAccounts": true,
		"DisablePocket": true,
		"DisplayBookmarksToolbar": "always",
		"ExtensionSettings": {
			"chrome-gnome-shell@gnome.org": {
				"installation_mode": "force_installed",
				"install_url": "https://addons.mozilla.org/firefox/downloads/latest/chrome-gnome-shell@gnome.org/latest.xpi"
			}
		},
		"Homepage": {
			"URL": "https://attend.seagl.org/",
			"StartPage": "homepage"
		},
		"NoDefaultBookmarks": true,
		"OverrideFirstRunPage": "",
		"SearchEngines": {
			"Default": "ddg@search.mozilla.org"
		},
		"SearchSuggestEnabled": true,
		"UserMessaging": {
			"SkipOnboarding": true
		}
	}
}
EOF
