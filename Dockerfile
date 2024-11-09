FROM debian-slim-10-30-2024 AS debian-10-30-2024
RUN apt update && apt install -y bc bison device-tree-compiler flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev zip
