FROM debian:bookworm-20241016-slim@sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56 AS omniteck-debian-slim
LABEL org.opencontainers.image.authors="shant@omniteck.com"
LABEL org.opencontainers.image.description="Tagged releases of debian docker images for reproducible build environments."
RUN sed -i 's,http://deb.debian.org/debian-security,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://deb.debian.org/debian,http://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Binary::apt-get::Acquire::AllowInsecureRepositories "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Immediate-Configure "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN apt update && apt install -y apt-transport-https ca-certificates
RUN sed -i 's,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,https://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://snapshot.debian.org/archive/debian/20241024T023111Z,https://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN apt update && apt upgrade -y && apt install -y build-essential lsb-release wget
