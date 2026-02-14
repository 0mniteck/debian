# [Debian-Dev Docker Images](https://hub.docker.com/r/0mniteck/)
Tagged releases of debian-dev docker images for reproducible build environments.

  |     Built     |    |         Scanned         |    |                 Signed                  |
  | ------------- | -- | ----------------------- | -- | --------------------------------------- |
  |               |    |                         |    |                                         |
  | ephemerally   |    | syft                    |    | yubikey (openpgp-rsa-2048/ssh-ecdsa-sk) |
  | rootlessly    |    | grype                   |    | in-toto (TSA attestation)               |
  | attestably    |    | scout (slim/base images)|    | docker provenance (attestation)         |

## Usage

### Use It!
 - #### Find pull instructions in the [Docker Hub](https://hub.docker.com/r/0mniteck/)
 - #### See other examples [0mniteck](https://github.com/0mniteck)
### Fork It!
 - A. Create a Docker Hub
 - B. Fork and edit the `.identity` file
 - C. Bump versions using the `.pinned_ver` file

### Build It!
Requirements:
 - aarch64/armv8/arm64 (rootless builds can't be CC'd)
 - Yubikey with CCID enabled is required for signing
 - Ubuntu 25.10 (will run on any debian distro with minor changes)

Build using `pkexec --keep-cwd ./buildscript.sh`

## Push Digests
https://github.com/0mniteck/Debian/blob/6a0bbd2a3708aa0936f05e598f5ece959d26c107/image.digests#L3-L4
https://github.com/0mniteck/Debian/blob/6a0bbd2a3708aa0936f05e598f5ece959d26c107/image.digests#L5-L6
https://github.com/0mniteck/Debian/blob/6a0bbd2a3708aa0936f05e598f5ece959d26c107/image.digests#L1-L2

## Grype Status at Buildtime
https://github.com/0mniteck/Debian/blob/3fcdccd50110dbc780356a02d5e09aaa5a3c30f4/readme.md?plain=1#L1-L5
https://github.com/0mniteck/Debian/blob/ce800ac65b99895fc6055c874c900fd2dfcb9c3a/readme.md?plain=1#L1-L5
https://github.com/0mniteck/Debian/blob/ce52934f82926299dc0de566c8391bbd9a3a1a9c/readme.md?plain=1#L1-L5

## Currently Supported Tagged Images/Snapshots

02/14/26:

`debian:trixie-20260202-slim
sha256:87e841c117299b7bfba269bd410cd1215f9aac28e8b3bab5d93117542e2636f1`

`https://snapshot.debian.org/archive/debian/20260213T203004Z`

`https://snapshot.debian.org/archive/debian-security/20260213T190147Z`

02/12/26:

`debian:trixie-20260202-slim
sha256:87e841c117299b7bfba269bd410cd1215f9aac28e8b3bab5d93117542e2636f1`

`https://snapshot.debian.org/archive/debian/20260212T204405Z`

`https://snapshot.debian.org/archive/debian-security/20260212T194631Z`

01/22/26:

`debian:trixie-20260112-slim
sha256:5a777b4bb3cfd59d2def8e0db5e3e70a9bfa262d7f5f2251a4b0ee84d7b45193`

`https://snapshot.debian.org/archive/debian/20260121T202109Z`

`https://snapshot.debian.org/archive/debian-security/20260120T213558Z`

## Included Packages
debian-slim: `build-essential curl git git-lfs libasound2-dev libgtk-3-dev libnss3-dev libpulse-dev lsb-release rubygems wget xauth xvfb`
### ↓
debian: `bc bison device-tree-compiler flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libgnutls28-dev libncurses-dev libssl-dev lzop nasm parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev zip`
### ↓
debian-extra: `acpica-tools adb adduser autoconf automake bzip2 ccache clang cmake codespell cpio cscope e2tools expect fastboot ftp-upload g++ gawk gcc gdb-multiarch gdisk gettext gperf help2man libattr1-dev libcap-ng-dev libclang-rt-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libpixman-1-dev libslirp-dev libstdc++6 libtext-template-perl libtool libtool-bin libusb-1.0-0-dev lld make meson mtools netcat-openbsd ninja-build patch python-is-python3 python3-cryptography python3-pip python3-pycodestyle python3-pycryptodome python3-serial rsync texinfo xalan xdg-utils xterm xz-utils zlib1g-dev`
