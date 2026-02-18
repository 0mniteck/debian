# [Debian-Dev Docker Images](https://hub.docker.com/r/0mniteck/)

Snapshot releases of debian-dev docker images for reproducible build environments.

  |     Built     |    |                 Signed                  |    |            Scanned            |
  | ------------- | -- | --------------------------------------- | -- | ----------------------------- |
  | attestably    |    | cosign  (keyless attestation via OIDC)  |    | scout (slim/base images)      |
  | ephemerally   |    | yubikey (openpgp-rsa-2048/ssh-ecdsa-sk) |    | syft  (images/OS/firmware)    |
  | rootlessly    |    | in-toto (github release TSA attestation)|    | grype (at buildtime)          |
  | immutably     |    | docker provenance (attestation)         |    | (low-to-no CVE's at buildtime)|

## Usage

### Use It!
 - #### Find pull instructions in the → [Docker Hub](https://hub.docker.com/r/0mniteck/)
 - #### See other examples → [0mniteck](https://github.com/0mniteck)

### [Fork It!](https://github.com/0mniteck/Debian/fork)
 - A. Create a Docker Hub
 - B. [Fork](https://github.com/0mniteck/Debian/fork) this repo and edit the `.identity` file
 - C. Manually set versions using the `.pinned_ver` file

### Build It!
Requirements:
 - Yubikey with CCID enabled is required for signing
 - linux/arm64 or linux/amd64 (Cross Compile supported - 5x slower)
 - Ubuntu 25.10 (will run on any debian distro with minor changes)

Clone `git clone https://github.com/$REPO/Debian.git && cd Debian`

Build using `./buildscript.sh` as a standard user

## [Push Digests](https://github.com/0mniteck/Debian/blob/builder/Results/image.digests) and Results
 - Full chain Software Bill of Materials (Docker/OS/Firmware)
   - Syft SBOM's `spdx.json`
   - Grype Scans/Results
   - Image Attestation/Digests/Signature
   - Provenance Metadata

### Docker Grype Status

https://github.com/0mniteck/Debian/blob/2e0266f34d6f7df852df812d9a61cbd3473d4c2e/readme.md?plain=1#L1-L7
https://github.com/0mniteck/Debian/blob/50ca39a36a2800a66b1c2dcdd5f229e45e0710b2/readme.md?plain=1#L1-L7
https://github.com/0mniteck/Debian/blob/325de3b18cdc1942b0bdee1a8a82f217cd97965e/readme.md?plain=1#L1-L7

### [OS Results](https://github.com/0mniteck/Debian/tree/builder/Results)

https://github.com/0mniteck/Debian/blob/6435dc9aee2029f66bf6f96f44ab8b4415651295/Results/readme.md?plain=1#L1-L11

### Firmware Scans

### [`U-Boot:/Results`](https://github.com/0mniteck/U-Boot/tree/v2025.04%2Bv2.12.1%2Bv4.5.0/Results)

## [Currently Tagged Image/Snapshots](https://github.com/0mniteck/Debian/releases)

 - [Low-to-No CVE's for current tag 2026-02-18](https://github.com/0mniteck/Debian/releases/tag/2026-02-18)

`debian:trixie-20260202-slim
sha256:f6e2cfac5cf956ea044b4bd75e6397b4372ad88fe00908045e9a0d21712ae3ba`

`https://snapshot.debian.org/archive/debian/20260218T142537Z`

`https://snapshot.debian.org/archive/debian-security/20260218T154409Z`
#
0mniteck's Current GPG Key ID: `287EE837E6ED2DD3`

<sup><sup>*Vigilant Mode is on for this repo so all remote pushes/tags should be signed with a verified key.</sup></sup>

## Included Packages
debian-slim: `build-essential curl git git-lfs libasound2-dev libgtk-3-dev libnss3-dev libpulse-dev lsb-release rubygems wget xauth xvfb`
### ↓
debian: `bc bison device-tree-compiler flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libgnutls28-dev libncurses-dev libssl-dev lzop nasm parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev zip`
### ↓
debian-extra: `acpica-tools adb adduser autoconf automake bzip2 ccache clang cmake codespell cpio cscope e2tools expect fastboot ftp-upload g++ gawk gcc gdb-multiarch gdisk gettext gperf help2man libattr1-dev libcap-ng-dev libclang-rt-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libpixman-1-dev libslirp-dev libstdc++6 libtext-template-perl libtool libtool-bin libusb-1.0-0-dev lld make meson mtools netcat-openbsd ninja-build patch python-is-python3 python3-cryptography python3-pip python3-pycodestyle python3-pycryptodome python3-serial rsync texinfo xalan xdg-utils xterm xz-utils zlib1g-dev`

## See also:
* [The Sovereignty Ephemerality Reproducibility (SER) framework](https://omniteck.com/?p=1104)
* https://snapshot.debian.org
* https://hub.docker.com/_/debian/tags
* https://gist.github.com/cybergitt/5bef4ab237de54038d3e6c68dd455a4e
