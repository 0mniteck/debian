# [Debian](https://hub.docker.com/r/0mniteck/)
Tagged releases of debian docker images for reproducible build environments.

## Grype Status at Buildtime

Debian Slim:
https://github.com/0mniteck/Debian/blob/#/readme.md?plain=1#L1-L3

Debian:
https://github.com/0mniteck/Debian/blob/#/readme.md?plain=1#L1-L3

Debian Extra:
https://github.com/0mniteck/Debian/blob/#/readme.md?plain=1#L1-L3

## Currently Supported Tagged Images/Snapshots

01/21/26:

`debian:trixie-20260112-slim
sha256:5a777b4bb3cfd59d2def8e0db5e3e70a9bfa262d7f5f2251a4b0ee84d7b45193`

`https://snapshot.debian.org/archive/debian/20260121T202109Z`

`https://snapshot.debian.org/archive/debian-security/20260120T213558Z`

10/16/25:

`debian:trixie-20250929-slim
sha256:c2242b938e28bd6f39c0372db589cfbb3a448fa593509f42ef887616e83d7047`

`https://snapshot.debian.org/archive/debian/20251016T204015Z`

`https://snapshot.debian.org/archive/debian-security/20251016T202337Z`

9/19/25:

`debian:trixie-20250908-slim
sha256:57801c95cab6cb8003835d78008f0ec0655bed246f9038be25df807427a1971d`

`https://snapshot.debian.org/archive/debian/20250919T203151Z`

`https://snapshot.debian.org/archive/debian-security/20250919T182858Z`


## Usage

`--remote` updates the submodules

`./buildscript.sh --remote`

## Included Packages
debian-slim: `build-essential curl git git-lfs libasound2-dev libgtk-3-dev libnss3-dev libpulse-dev lsb-release rubygems wget xauth xvfb`
### ↓
debian: `bc bison device-tree-compiler flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libgnutls28-dev libncurses-dev libssl-dev lzop nasm parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev zip`
### ↓
debian-extra: `acpica-tools adb adduser autoconf automake bzip2 ccache clang cmake codespell cpio cscope e2tools expect fastboot ftp-upload g++ gawk gcc gdb-multiarch gdisk gettext gperf help2man libattr1-dev libcap-ng-dev libclang-rt-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libpixman-1-dev libslirp-dev libstdc++6 libtext-template-perl libtool libtool-bin libusb-1.0-0-dev lld make meson mtools netcat-openbsd ninja-build patch python-is-python3 python3-cryptography python3-pip python3-pycodestyle python3-pycryptodome python3-serial rsync texinfo xalan xdg-utils xterm xz-utils zlib1g-dev`

## Old Tags

8/23/25:

`debian:trixie-20250811-slim
sha256:35970418eb2600fee5e2c0990f6d2754f2db63485b9f73ac220ef2f514ca04b7`

`https://snapshot.debian.org/archive/debian/20250823T144135Z`

`https://snapshot.debian.org/archive/debian-security/20250823T124534Z`

8/9/25:

`debian:trixie-20250721-slim
sha256:77c8f9d6272a913f5c5aaadd9bf97dfc29717001b7c0577b39a389f74d0dd560`

`https://snapshot.debian.org/archive/debian/20250809T023713Z`

`https://snapshot.debian.org/archive/debian-security/20250809T070340Z`

7/4/25:

`debian:bookworm-20250630-slim
sha256:6ac2c08566499cc2415926653cf2ed7c3aedac445675a013cc09469c9e118fdd`

`https://snapshot.debian.org/archive/debian/20250704T143531Z`

`https://snapshot.debian.org/archive/debian-security/20250704T170049Z`

5/20/25:

`debian:bookworm-20250520-slim
sha256:f41950d5d084b96ee49ad4c872319f5afce6667bcc99b6bb318df03cd0621ad6`

`https://snapshot.debian.org/archive/debian/20250520T202712Z`

`https://snapshot.debian.org/archive/debian-security/20250520T202737Z`

4/24/25:

`debian:bookworm-20250407-slim
sha256:912d8a461ca5f85380a40de97d7b38dfcc39972de210518de07136126dd0bfa9`

`https://snapshot.debian.org/archive/debian/20250424T144915Z`

`https://snapshot.debian.org/archive/debian-security/20250424T134513Z`

3/17/25:

`debian:bookworm-20250317-slim
sha256:1209d8fd77def86ceb6663deef7956481cc6c14a25e1e64daec12c0ceffcc19d`

`https://snapshot.debian.org/archive/debian/20250317T205300Z`

`https://snapshot.debian.org/archive/debian-security/20250317T194126Z`

2/24/25:

`debian:bookworm-20250224-slim
sha256:d03c875b13ee95b71bf0977cb17e409655d8dbe5ccbbb7ffedaceb69c8027279`

`https://snapshot.debian.org/archive/debian/20250224T204949Z`

`https://snapshot.debian.org/archive/debian-security/20250224T221440Z`

1/13/25:

`debian:bookworm-20250113-slim
sha256:34cd1c3529899fd810cb571dff498834235748a95d1c36008f022e93f5653128`

`https://snapshot.debian.org/archive/debian/20250112T145927Z`

`https://snapshot.debian.org/archive/debian-security/20250112T130311Z`

12/23/24:

`debian:bookworm-20241223-slim
sha256:d365f4920711a9074c4bcd178e8f457ee59250426441ab2a5f8106ed8fe948eb`

`https://snapshot.debian.org/archive/debian/20241223T205427Z`

`https://snapshot.debian.org/archive/debian-security/20241223T165327Z`

12/2/24:

`debian:bookworm-20241202-slim
sha256:e7e7d7fa8fd16e9004b3ffea68e030a8ede97a747b3ebd77f9ea597bb6e7fc00`

`https://snapshot.debian.org/archive/debian/20241202T203942Z`

`https://snapshot.debian.org/archive/debian-security/20241202T225754Z`

11/11/24:

`debian:bookworm-20241111-slim
sha256:046de794712cf47a9ea8995d8f8d77f61230d8da7655b6dbfa1eb1b86feabbf5d`

`https://snapshot.debian.org/archive/debian/20241111T203302Z`

`https://snapshot.debian.org/archive/debian-security/20241111T212343Z`

11/09/24:

`debian:bookworm-20241016-slim
sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56`

`https://snapshot.debian.org/archive/debian/20241109T082826Z`

`https://snapshot.debian.org/archive/debian-security/20241109T084744Z`
