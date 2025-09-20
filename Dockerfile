ARG SOURCE=debian-slim:trixie
FROM $SOURCE AS omniteck-debian-slim
LABEL org.opencontainers.image.authors="shant@omniteck.com"
LABEL org.opencontainers.image.vendor="OMNITECK"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.description="Tagged releases of debian docker images for reproducible build environments."
RUN mkdir /.cache && chmod -R 777 /.cache
ARG DEBIAN_SECURITY
ARG DEBIAN
RUN sed -i 's,http://deb.debian.org/debian-security,https://snapshot.debian.org/archive/debian-security/'$DEBIAN_SECURITY',g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://deb.debian.org/debian,https://snapshot.debian.org/archive/debian/'$DEBIAN',g' /etc/apt/sources.list.d/debian.sources
RUN apt update && apt upgrade -y && apt install -y build-essential curl git git-lfs lsb-release wget
