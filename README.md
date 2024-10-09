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
- Github Workflows
  - https://docs.github.com/en/actions/using-workflows

# Installation

This procedure was tested on one of the conference's streaming laptops; you may need to adjust otherwise.

1. Write and boot a Fedora Silverblue (as of October 2024, version 40) installer.
2. Select Automatic partitioning and check the checkbox to free space by removing or resizing existing partitions.
3. When prompted, remove **all** partitions, including and especially the EFI System Partition.
4. Run the installer.
5. TODO.

# How to Use

## Containerfile

This file defines the operations used to customize the selected image. It contains examples of possible modifications, including how to:
- change the upstream from which the custom image is derived
- add additional RPM packages
- add binaries as a layer from other images
