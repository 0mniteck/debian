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
 - #### Find pull instructions in the → [Docker Hub](https://hub.docker.com/r/0mniteck/)
 - #### See other examples → [0mniteck](https://github.com/0mniteck)
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

## Push Digests and Grype Status
https://github.com/0mniteck/Debian/blob/ff892f79bcf28bc56c503a0a8f19c39eabb76dfe/image.digests#L3-L4
https://github.com/0mniteck/Debian/blob/6ee9b6bc2501e86e2df290e24282a8a7530f77a3/readme.md?plain=1#L1-L3

https://github.com/0mniteck/Debian/blob/ff892f79bcf28bc56c503a0a8f19c39eabb76dfe/image.digests#L5-L6
https://github.com/0mniteck/Debian/blob/16e7b1508378018b8278bc9dc1874aee1b7c4640/readme.md?plain=1#L1-L3

https://github.com/0mniteck/Debian/blob/ff892f79bcf28bc56c503a0a8f19c39eabb76dfe/image.digests#L1-L2
https://github.com/0mniteck/Debian/blob/7ee312f0ccccb9aca63bb8912b258860f9b0646f/readme.md?plain=1#L1-L3

## Currently Tagged Image/Snapshots

`debian:trixie-20260202-slim
sha256:87e841c117299b7bfba269bd410cd1215f9aac28e8b3bab5d93117542e2636f1`

`https://snapshot.debian.org/archive/debian/20260216T082402Z`

`https://snapshot.debian.org/archive/debian-security/20260216T100331Z`

## Included Packages
debian-slim: `build-essential curl git git-lfs libasound2-dev libgtk-3-dev libnss3-dev libpulse-dev lsb-release rubygems wget xauth xvfb`
### ↓
debian: `bc bison device-tree-compiler flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libgnutls28-dev libncurses-dev libssl-dev lzop nasm parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev zip`
### ↓
debian-extra: `acpica-tools adb adduser autoconf automake bzip2 ccache clang cmake codespell cpio cscope e2tools expect fastboot ftp-upload g++ gawk gcc gdb-multiarch gdisk gettext gperf help2man libattr1-dev libcap-ng-dev libclang-rt-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libpixman-1-dev libslirp-dev libstdc++6 libtext-template-perl libtool libtool-bin libusb-1.0-0-dev lld make meson mtools netcat-openbsd ninja-build patch python-is-python3 python3-cryptography python3-pip python3-pycodestyle python3-pycryptodome python3-serial rsync texinfo xalan xdg-utils xterm xz-utils zlib1g-dev`
