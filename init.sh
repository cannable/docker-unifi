#!/bin/bash

# ------------------------------------------------------------------------------
# Unifi Network Controller Starter Script
# ------------------------------------------------------------------------------

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

UNIFI_DATADIR=/usr/lib/unifi/data
UNIFI_RUNDIR=/usr/lib/unifi/run
UNIFI_LOGDIR=/usr/lib/unifi/logs


# JVM Options
JVM_OPTS=""
JVM_OPTS="${JVM_OPTS} -Djava.awt.headless=true"
JVM_OPTS="${JVM_OPTS} -Dfile.encoding=UTF-8"
JVM_OPTS="${JVM_OPTS} -Xmx${JVM_MAXHEAP}"
JVM_OPTS="${JVM_OPTS} -Dunifi.datadir=${UNIFI_DATADIR}"
JVM_OPTS="${JVM_OPTS} -Dunifi.rundir=${UNIFI_RUNDIR}"
JVM_OPTS="${JVM_OPTS} -Dunifi.logdir=${UNIFI_LOGDIR}"
JVM_OPTS="${JVM_OPTS} -cp /usr/share/java/commons-daemon.jar:/usr/lib/unifi/lib/ace.jar"


# Ensure data directories are set up properly
for dpath in "${UNIFI_DATADIR}" "${UNIFI_RUNDIR}" "${UNIFI_LOGDIR}"; do

    mkdir -p "${dpath}"

    chown -R unifi:unifi "${dpath}"
    chmod 750 "${dpath}"

    find "${dpath}" -type d ! -perm 0750 -exec chmod 0750 \{\} \;
    find "${dpath}" -type f ! -perm 0640 -exec chmod 0640 \{\} \;
done

# Start Unifi
su -s /bin/bash -c "java ${JVM_OPTS} -jar /usr/lib/unifi/lib/ace.jar start" unifi
