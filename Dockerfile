FROM ubuntu:18.04

# NOTE: To build this container image, you must have the Unifi controller
# package downloaded somewhere already. Use ./util/build.sh to avoid this.

ARG UNIFI_VERSION=7.0.21
ARG UNIFI_PKG_PATH=./cache/7.0.21-unifi_sysvinit_all.deb

ENV NAME unifi
ENV JVM_MAXHEAP=1024m

VOLUME ["/usr/lib/unifi/data", \
        "/usr/lib/unifi/logs"]

COPY ${UNIFI_PKG_PATH} /unifi_sysvinit_all.deb
COPY ./init.sh /init.sh

RUN apt-get update && \
        apt-get --no-install-recommends -y install openjdk-8-jre-headless /unifi_sysvinit_all.deb && \
        rm -f /unifi_sysvinit_all.deb && \
        apt-get -y clean && \
        rm -rf /var/lib/apt/lists/*


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

ENTRYPOINT ["/bin/bash", "/init.sh"]
