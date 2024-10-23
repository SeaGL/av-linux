## 1. BUILD ARGS
# These allow changing the produced image by passing different build args to adjust
# the source from which your image is built.
# Build args can be provided on the commandline when building locally with:
#   podman build -f Containerfile --build-arg FEDORA_VERSION=40 -t local-image

# SOURCE_IMAGE arg can be anything from ublue upstream which matches your desired version:
# See list here: https://github.com/orgs/ublue-os/packages?repo_name=main
# - "silverblue"
# - "kinoite"
# - "sericea"
# - "onyx"
# - "lazurite"
# - "vauxite"
# - "base"
#
#  "aurora", "bazzite", "bluefin" or "ucore" may also be used but have different suffixes.
ARG SOURCE_IMAGE="base"

## SOURCE_SUFFIX arg should include a hyphen and the appropriate suffix name
# These examples all work for silverblue/kinoite/sericea/onyx/lazurite/vauxite/base
# - "-main"
# - "-nvidia"
# - "-asus"
# - "-asus-nvidia"
# - "-surface"
# - "-surface-nvidia"
#
# aurora, bazzite and bluefin each have unique suffixes. Please check the specific image.
# ucore has the following possible suffixes
# - stable
# - stable-nvidia
# - stable-zfs
# - stable-nvidia-zfs
# - (and the above with testing rather than stable)
ARG SOURCE_SUFFIX="-main"

## SOURCE_TAG arg must be a version built for the specific image: eg, 39, 40, gts, latest
ARG SOURCE_TAG="40"
ARG FEDORA_MAJOR_VERSION=${FEDORA_MAJOR_VERSION}


### 2. SOURCE IMAGE
## this is a standard Containerfile FROM using the build ARGs above to select the right upstream image
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}


### 3. MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY build.sh /tmp/build.sh
COPY osrelease.sh /tmp/osrelease.sh
COPY flathub.flatpakrepo /tmp/flathub.flatpakrepo
# Apparently Buildah doesn't support --checksum :/
# TODO --checksum=shas56:b36536d919a8fcb5de966f846bd6ca70dc6af3295bc64b1b9dde2b50c07c873c
ADD https://extensions.gnome.org/extension-data/appmenu-is-backfthx.v3.shell-extension.zip /tmp/
# TODO --checksum=sha256:6766341c77739ec9dcdc439ea20f83c31a4863750ecdd4d11a74faaa60510449
ADD https://extensions.gnome.org/extension-data/grand-theft-focuszalckos.github.com.v7.shell-extension.zip /tmp/

COPY bin/* /usr/bin/
COPY sbin/* /usr/sbin/
COPY systemd/* /usr/lib/systemd/system/
COPY desktops/* /usr/share/applications/
COPY misc/seagl-state-dir.conf /usr/lib/tmpfiles.d/
COPY icon/seagl-logo-icon.svg /usr/share/icons/hicolor/scalable/places/
COPY etc/* /etc/

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
