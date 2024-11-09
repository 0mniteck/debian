FROM debian-10-30-2024 AS debian-extra-10-30-2024
RUN apt update && apt install -y adb acpica-tools autoconf automake ccache cpio cscope curl e2tools expect fastboot ftp-upload gdisk git libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libpixman-1-dev libslirp-dev libtool libusb-1.0-0-dev make mtools netcat-openbsd ninja-build python3-cryptography python3-pip python3-serial python-is-python3 rsync xalan xdg-utils xterm xz-utils zlib1g-dev
