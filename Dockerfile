ARG REL_DATE=latest
FROM 0mniteck/debian-slim:$REL_DATE AS omniteck-debian
RUN apt update && apt install -y bc bison device-tree-compiler flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libgnutls28-dev libncurses-dev libssl-dev lzop nasm parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev zip
