ARG SOURCE
FROM $SOURCE AS omniteck-debian-slim
LABEL org.opencontainers.image.authors="shant@omniteck.com"
LABEL org.opencontainers.image.description="Tagged releases of debian docker images for reproducible build environments."
ARG DEBIAN_SECURITY
ARG DEBIAN
RUN sed -i 's,http://deb.debian.org/debian-security,http://snapshot.debian.org/archive/debian-security/$DEBIAN_SECURITY,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://deb.debian.org/debian,http://snapshot.debian.org/archive/debian/$DEBIAN,g' /etc/apt/sources.list.d/debian.sources
RUN echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Binary::apt-get::Acquire::AllowInsecureRepositories "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Immediate-Configure "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN apt update && apt install -y apt-transport-https ca-certificates
RUN sed -i 's,http://snapshot.debian.org/archive/debian-security/$DEBIAN_SECURITY,https://snapshot.debian.org/archive/debian-security/$DEBIAN_SECURITY,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://snapshot.debian.org/archive/debian/$DEBIAN,https://snapshot.debian.org/archive/debian/$DEBIAN,g' /etc/apt/sources.list.d/debian.sources
RUN apt update && apt upgrade -y && apt install -y build-essential lsb-release wget
