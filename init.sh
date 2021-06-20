#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/


# Ensure data directories are set up properly
for dname in run data logs; do

    dpath="/usr/lib/unifi/${dname}"

    mkdir -p "${dpath}"

    chown -R unifi:unifi "${dpath}"
    chmod 750 "${dpath}"

    find "${dpath}" -type d ! -perm 0750 -exec chmod 0750 \{\} \;
    find "${dpath}" -type f ! -perm 0640 -exec chmod 0640 \{\} \;
done

su -s /bin/bash -c "java -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Xmx${JVM_MAXHEAP} -jar /usr/lib/unifi/lib/ace.jar start" unifi