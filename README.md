# docker-unifi

This is what it sounds like - the Unifi Controller in a Docker container.

## Heads Up - Mongodb 3.6

In the event I am not the only one using this image, you will need to work around some annoyances I am creating. I am now building these images off of Ubuntu 18.04, which has mongodb 3.6.x (versus the 3.2.x in Debian Stretch). The reason is simple - 3.2 isn't supported by the main project anymore, and Ubiquiti supports 3.6 now.

Starting with builds after 6.2.25, you're likely going to have issues doing an in-place upgrade (it exploded for me when I tested it, for example). I have ideas as to why, and maybe how to fix them properly, but here's the easiest workaround: do a manual backup first.

A special tagged image exists for doing the upgrade (6.2.25-mongodb36). Docker will only keep this image around a few months, so you should plan around migrating soon. If you're not ready just yet, switch to 6.2.25-mongodb32. To migrate, do the following:

1. Perform a manual backup from the Unifi console
1. If you replaced the Unifi certificate, back up your custom keystore file
1. Delete your existing container and volumes
1. Run the new container (ex. using the 6.2.25-mongodb36 tag)
1. Upload your backup file to the installer
1. Wait for the restore to finish, then log in and check on your sites
1. Restore your custom keystore, if you had one
1. Do a regular backup of your controller

## Tags

I build images for three architectures:

| Platform | Tag Prefix |
| -------- | ---------- |
| amd64 | amd64 |
| aarch64 | arm64 |
| ARMv7 | arm * |

Each platform's images are tagged with the convention prefix-version, so arm64-6.2.25 would be the aarch64 build for the v6.2.25 controller. Manifests are built for each version so, if you are just pulling this with the intention to run it, you can just pull cannable/unifi:6.2.25, or latest.

* NOTE: 32-bit ARM builds are broken right now.

## Old Tags/Images

I ended up doing a large refactoring of how this container works and how I build images. The first thing was to ditch s6 because I wasn't actually using it for anything and it was adding unnecessary complexity. Besides, I'd rather have docker get stderr/stdout from java.

The other major thing is why I added this section - I am building these with buildah now. Due to a number of things, including some general laziness on my end, the tag prefix for 32-bit arm has changed from "armhf" to just "arm". I've also managed to break the build on that platform, so... yeah.

I run this image off of a Pi running Photon and build these on an amd64 box, so I kind of lack a "proper" environment to test that arch. Mongodb uses a different DB engine too and switching to 64 bit is "interesting" (if you happen to do that, the path of least resistance is to save a backup from the Maintenance area in the Unifi console, nuke your container, then start a new 64-bit one up and restore the backup). It's possible some older builds are also broken and I didn't spot it. I probably should make my build scripts bail if something goes wrong in apt land.

## Run-Time Configuration

**JVM_MAXHEAP**

Set this to change the Xmx value used to start Unifi. Defaults to 1024m (which is the Unifi default).

## Build-Time Configuration

**UNIFI_VERSION**

Define this to install a specific version of the controller. The latest version provided by Ubiquiti's APT repo is installed if this argument is empty. When you define this, the deb archive will be downloaded from Ubiquiti's site.

NOTE: You must explicity pass a version number if building on aarch64 (same goes for any odd-ball platforms UBNT doesn't directly support). Ubiquiti's APT repo does not have packages or an index for this platform, even though the package we install is marked as noarch.

## Volumes

There are two defined in the Dockerfile. You should probably redirect these:

* /usr/lib/unifi/data/
* /usr/lib/unifi/logs/

## Other Stuff

You should consider running this container on either a macvlan or ipvlan network. This is how I run this container. Most of the required ports are exposed by default, but because I don't test all functionality in my environment, I can't guarantee something isn't horribly broken somewhere.

There's room for improvement in a number of areas in this container. Most notably, logging is a bit of a mess (in that I made no effort to get it working properly). Unifi craps out trying to write log files and mongodb could use some rotation set up. Consider that the largest TODO item.
