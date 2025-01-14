# [debian](https://hub.docker.com/r/0mniteck/)
Tagged releases of debian docker images for reproducible build environments.

## Currently Tagged Images/Snapshots

1/13/25:

`debian:bookworm-20250113-slim
sha256:34cd1c3529899fd810cb571dff498834235748a95d1c36008f022e93f5653128`

`http://snapshot.debian.org/archive/debian/20250112T145927Z`

`http://snapshot.debian.org/archive/debian-security/20250112T130311Z`

12/23/24:

`debian:bookworm-20241223-slim
sha256:d365f4920711a9074c4bcd178e8f457ee59250426441ab2a5f8106ed8fe948eb`

`http://snapshot.debian.org/archive/debian/20241223T205427Z`

`http://snapshot.debian.org/archive/debian-security/20241223T165327Z`

12/2/24:

`debian:bookworm-20241202-slim
sha256:e7e7d7fa8fd16e9004b3ffea68e030a8ede97a747b3ebd77f9ea597bb6e7fc00`

`http://snapshot.debian.org/archive/debian/20241202T203942Z`

`http://snapshot.debian.org/archive/debian-security/20241202T225754Z`

## Usage

`--remote` updates the submodules

`./buildscript.sh --remote`

## Included Packages
debian-slim: `build-essential curl git git-lfs lsb-release wget`
### ↓
debian: `bc bison device-tree-compiler flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev zip`
### ↓
debian-extra: `adb acpica-tools autoconf automake ccache cpio cscope e2tools expect fastboot ftp-upload gdisk libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libpixman-1-dev libslirp-dev libtool libusb-1.0-0-dev make mtools netcat-openbsd ninja-build python3-cryptography python3-pip python3-serial python-is-python3 rsync xalan xdg-utils xterm xz-utils zlib1g-dev`

## Old Tags

11/11/24:

`debian:bookworm-20241111-slim
sha256:046de794712cf47a9ea8995d8f8d77f61230d8da7655b6dbfa1eb1b86feabbf5d`

`http://snapshot.debian.org/archive/debian/20241111T203302Z`

`http://snapshot.debian.org/archive/debian-security/20241111T212343Z`

11/09/24:

`debian:bookworm-20241016-slim
sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56`

`http://snapshot.debian.org/archive/debian/20241109T082826Z`

`http://snapshot.debian.org/archive/debian-security/20241109T084744Z`

10/30/24:

`debian:bookworm-20241016-slim
sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56`

`http://snapshot.debian.org/archive/debian/20241024T023111Z`

`http://snapshot.debian.org/archive/debian-security/20241024T023334Z`
