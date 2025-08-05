#!/usr/bin/bash

# Cribbed and somewhat modified from https://github.com/ublue-os/bazzite/blob/85a1e0d275f5699416a61ad483aba649333de16d/system_files/desktop/shared/usr/libexec/containerbuild/image-info
# Apache 2.0

set -euo pipefail

IMAGE_VENDOR="SeaGL"
IMAGE_NAME="av-linux"
IMAGE_BRANCH="main"
IMAGE_FLAVOR="main"
# TODO figure out why these aren't inherited from Containerfile ARG
SOURCE_IMAGE="silverblue"
FEDORA_MAJOR_VERSION="40"
BASE_IMAGE_NAME="${SOURCE_IMAGE^}"

IMAGE_PRETTY_NAME="SeaGL Aviary Linux"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/SeaGL/av-linux"
DOCUMENTATION_URL="https://github.com/SeaGL/av-linux/blob/main/README.md"
SUPPORT_URL="https://seagl.org/chat"
BUG_SUPPORT_URL="https://github.com/SeaGL/av-linux/issues"
LOGO_ICON="seagl-logo-icon"
# TODO
LOGO_COLOR="0;38;2;138;43;226"
CODE_NAME="2024"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"
IMAGE_BRANCH_NORMALIZED=$IMAGE_BRANCH

if [[ $IMAGE_BRANCH_NORMALIZED == "main" ]]; then
  IMAGE_BRANCH_NORMALIZED="stable"
fi

case "$FEDORA_MAJOR_VERSION" in
  39|40)
    IMAGE_TAG="stable"
    ;;
  *)
    IMAGE_TAG="$FEDORA_MAJOR_VERSION"
    ;;
esac

# Image Info File
cat > $IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$IMAGE_FLAVOR",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag": "$IMAGE_TAG",
  "image-branch": "$IMAGE_BRANCH_NORMALIZED",
  "base-image-name": "$BASE_IMAGE_NAME",
  "fedora-version": "$FEDORA_MAJOR_VERSION",
  "version": "$CODE_NAME",
  "version-pretty": "$CODE_NAME"
}
EOF

# OS Release File
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"$IMAGE_PRETTY_NAME $CODE_NAME (FROM Fedora ${BASE_IMAGE_NAME^} $FEDORA_MAJOR_VERSION)\"|" /usr/lib/os-release
sed -i "s|^NAME=.*|NAME=\"$IMAGE_PRETTY_NAME\"|" /usr/lib/os-release
sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" /usr/lib/os-release
sed -i "/SUPPORT_URL/d" /usr/lib/os-release
sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
sed -i "/DEFAULT_HOSTNAME=/d" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=seaglav\nID_LIKE=\"${IMAGE_LIKE}\"/" /usr/lib/os-release
sed -i "s/^LOGO=.*/LOGO=$LOGO_ICON/" /usr/lib/os-release
sed -i "s/^ANSI_COLOR=.*/ANSI_COLOR=\"$LOGO_COLOR\"/" /usr/lib/os-release
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release
sed -i "s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"$CODE_NAME\"|" /usr/lib/os-release

if [[ -n "${SHA_HEAD_SHORT:-}" ]]; then
  echo "BUILD_ID=\"$SHA_HEAD_SHORT\"" >> /usr/lib/os-release
fi

echo "BOOTLOADER_NAME=\"$IMAGE_PRETTY_NAME $CODE_NAME\"" >> /usr/lib/os-release

# Fix issues caused by ID no longer being fedora
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg
