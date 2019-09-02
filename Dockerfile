FROM debian:stretch

ENV NAME unifi

COPY ["./data", "/data"]
RUN ["/bin/bash", "/data/build.sh"]

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

EXPOSE "8080/tcp" \
       "8443/tcp" \
       "8880/tcp" \
       "8843/tcp" \
       "6789/tcp" \
       "27117/tcp" \
       "5656-5699/udp" \
       "10001/udp" \
       "1900/udp"

ENTRYPOINT ["/init"]
