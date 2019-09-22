# docker-unifi

This is what it sounds like - the Unifi Controller in a Docker container.

## Run-Time Configuration

**JVM_MAXHEAP**

Set this to change the Xmx value used to start Unifi. Defaults to 1024m (which is the Unifi default).

## Build-Time Configuration

**UNIFI_VERSION**

Define this to install a specific version of the controller. The latest version provided by Ubiquiti's APT repo is installed if this argument is empty. When you define this, the deb archive will be downloaded from Ubiquiti's site.

NOTE: You must explicity pass a version number if building on aarch64 (same goes for any odd-ball platforms UBNT doesn't directly support). Ubiquiti's APT repo does not have packages or an index for this platform, even though the package we install is marked as noarch.

**S6_VERSION**

This package uses s6-overlay from just-containers (<https://github.com/just-containers/s6-overlay>). There's a default version defined in the Dockerfile that will be bumped when/if I remember. If you want a specific version, pass this argument.

## Volumes

There are two defined in the Dockerfile. You should probably redirect these:

* /usr/lib/unifi/data/
* /usr/lib/unifi/logs/

## Other Stuff

You should consider running this container on either a macvlan or ipvlan network. This is how I run this container. Most of the required ports are exposed by default, but because I don't test all functionality in my environment, I can't guarantee something isn't horribly broken somewhere.