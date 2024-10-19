FROM ubuntu:22.04

# NOTE: To build this container image, you must have the Unifi controller
# package downloaded somewhere already. Use ./util/build.sh to avoid this.

ARG UNIFI_VERSION=8.1.127
ARG UNIFI_PKG_PATH=./cache/8.1.127-UniFi.unix.zip 

ENV NAME unifi
ENV JVM_MAXHEAP=1024m
ENV UNIFI_UID=102
ENV UNIFI_GID=103

COPY ${UNIFI_PKG_PATH} /UniFi.unix.zip
COPY ./init.sh /init.sh

# Install pre-reqs
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  adduser \
  apt-transport-https \
  binutils \
  ca-certificates \
  coreutils \
  curl \
  gnupg \
  libcap2 \
  logrotate \
  unzip && \
  mkdir -p /etc/apt/keyrings && \
  curl -o /etc/apt/keyrings/adoptium.asc https://packages.adoptium.net/artifactory/api/gpg/key/public && \
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb jammy main" > /etc/apt/sources.list.d/adoptium.list && \
  curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor && \
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list && \
  apt-get update && \
  apt-get install --no-install-recommends -y temurin-17-jre mongodb-org && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /usr/lib && \
  unzip /UniFi.unix.zip -d /usr/lib && \
  mv /usr/lib/UniFi /usr/lib/unifi && \
  mkdir -p /usr/lib/unifi/data && \
  mkdir -p /usr/lib/unifi/logs


# Ports stolen from here:
# https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used

# UDP 	3478 	Port used for STUN.
# TCP 	8080 	Port used for device and controller communication.
# TCP 	8443 	Port used for controller GUI/API as seen in a web browser
# TCP 	8880 	Port used for HTTP portal redirection.
# TCP 	8843 	Port used for HTTPS portal redirection.
# TCP 	6789 	Port used for UniFi mobile speed test.
# TCP 	27117 	Port used for local-bound database communication.
# UDP 	5656-5699 	Ports used by AP-EDU broadcasting.
# UDP 	10001 	Port used for device discovery
# UDP 	1900 	Port used for "Make controller discoverable on L2 network" in controller settings.

EXPOSE "3478/udp" \
  "8080/tcp" \
  "8443/tcp" \
  "8880/tcp" \
  "8843/tcp" \
  "6789/tcp" \
  "5656-5699/udp" \
  "10001/udp" \
  "1900/udp"

VOLUME ["/usr/lib/unifi/data", \
  "/usr/lib/unifi/logs"]

ENTRYPOINT ["/bin/bash", "/init.sh"]

