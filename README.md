# docker-unifi

This is what it sounds like - the Unifi Controller in a Docker container.

## News, of Sorts

### New Build Behaviour

To speed up cross-architecture builds and reduce bandwidth consumed, this image
expects you to supply the Debian package for the Unifi controller. This only
matters if you build the image yourself without using ./util/build.sh. FYI -
that build script will now create a cache directory.

## Tags

I build images for three architectures:

| Platform | Tag Prefix |
| -------- | ---------- |
| amd64 | amd64 |
| aarch64 | arm64 |

Each platform's images are tagged with the convention prefix-version, so
arm64-6.2.25 would be the aarch64 build for the v6.2.25 controller. Manifests
are built for each version so, if you are just pulling this with the intention
to run it, you can just pull cannable/unifi:6.2.25, or latest.

## Run-Time Configuration

**JVM_MAXHEAP**

Set this to change the Xmx value used to start Unifi. Defaults to 1024m (which
is the Unifi default).

### Secrets

Added to 7.3.83 images.

**UNIFI_HTTPS_KEY_FILE and UNIFI_HTTPS_CERT_FILE**

Set these to the paths containing custom HTTPS private & public keys. The paths
are inside the container and both must exist for things to work.

**UNIFI_HTTPS_CACERT_FILE and UNIFI_HTTPS_CA_ALIAS**

Set `UNIFI_HTTPS_CACERT_FILE` to the path to a custom CA cert that should be imported into the trust store.

Set `UNIFI_HTTPS_CA_ALIAS` to the alias/name of the CA cert in the trust store. This is optional and defaults to "custom_ca" if undefined.

## Build-Time Configuration

**UNIFI_VERSION**

Version of the Ubiquiti Network Application to package. Mostly used for tagging.

**UNIFI_PKG_PATH**

Path on disk (host/builder) where the Unifi Network Application's Debian package
resides.

## Volumes

There are two defined in the Dockerfile. You should probably redirect these:

* /usr/lib/unifi/data/
* /usr/lib/unifi/logs/

## Other Stuff

You should consider running this container on either a macvlan or ipvlan
network. This is how I run this container. Most of the required ports are
exposed by default, but because I don't test all functionality in my
environment, I can't guarantee something isn't horribly broken somewhere.

There's room for improvement in a number of areas in this container. Most
notably, logging is a bit of a mess (in that I made no effort to get it working
properly). Unifi craps out trying to write log files and mongodb could use some
rotation set up. Consider that the largest TODO item.

Right now, this will only build 7.x container images. I am going to fix that
sometime. If you want to build 6.x or older images, checkout the `6.x-or-older`
tag. Be warned - anything older than 6.5.55 has potentially catastrophic log4j
vulnerabilities.