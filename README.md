# av-linux

# Purpose

This is a purpose-built, atomic/immutable Linux operating system designed to have everything needed to run live broadcasting on-site at [SeaGL](https://seagl.org/). It is intended to be installed on laptops that run broadcasting in each talk room, and is based on [Universal Blue](https://github.com/ublue-os) which is itself based on [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/).

This template includes a Containerfile and a GitHub workflow for building the container image. Commits trigger container builds that are pushed to GitHub Container Registry.

# Prerequisites

Working knowledge in the following topics:

- Containers
  - https://www.youtube.com/watch?v=SnSH8Ht3MIc
  - https://www.mankier.com/5/Containerfile
- rpm-ostree
  - https://coreos.github.io/rpm-ostree/container/
- Fedora Silverblue (and other Fedora Atomic variants)
  - https://docs.fedoraproject.org/en-US/fedora-silverblue/
- GitHub Workflows
  - https://docs.github.com/en/actions/using-workflows

# Installation

This procedure was tested on one of the conference's streaming laptops; you may need to adjust otherwise.

1. Write and boot a Fedora Silverblue (as of October 2024, version 40) installer. On conference laptops, the boot menu key is F12.
2. Select Automatic partitioning and check the checkbox to free space by removing or resizing existing partitions.
3. When prompted, remove **all** partitions, including and especially the EFI System Partition.
4. Run the installer.
5. Reboot.
6. Go through setup.
   1. Connect to WiFi.
   2. Leave location services enabled.
   3. Enable Third-Party Repositories and click Next.
   4. Set Full Name to "SeaGL Provisioning".
   5. Accept the default username of `seaglprovisioning`.
   6. Set the password to `password`.
9. Apply firmware updates in GNOME Software, if applicable. **This is very important** as once you've switched to Aviary Linux, you can't apply these anymore due to EFI partition naming shenanigans.
8. In a terminal, run `sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/seagl/av-linux:latest`. You can monitor progress of this step with `rpm-ostree status` and `sudo journalctl -fu rpm-ostreed.service`.
9. When `rpm-ostree status` reports `Status: idle`, reboot.
10. In a terminal, rebase to the signed image with `sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/seagl/av-linux:latest`.
11. When `rpm-ostree status` reports `Status: idle`, reboot.

# How to Use

## Containerfile

This file defines the operations used to customize the selected image. It contains examples of possible modifications, including how to:
- change the upstream from which the custom image is derived
- add additional RPM packages
- add binaries as a layer from other images
