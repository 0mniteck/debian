ARG REL_DATE=latest
FROM 0mniteck/debian:$REL_DATE AS omniteck-debian-extra
RUN apt update && apt install -y adb acpica-tools autoconf automake ccache cpio cscope clang cmake e2tools expect fastboot ftp-upload gdisk gcc g++ libclang-rt-dev libstdc++6 lld libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libpixman-1-dev libslirp-dev libtext-template-perl libtool libusb-1.0-0-dev make mtools netcat-openbsd ninja-build patch python3-pycryptodome python3-pycodestyle python3-cryptography python3-pip python3-serial python-is-python3 rsync xalan xdg-utils xterm xz-utils zlib1g-dev
RUN cpan -i Text::Template
