#!/bin/bash

# ------------------------------------------------------------------------------
# Unifi Network Controller Starter Script
# ------------------------------------------------------------------------------


### Environment Variables

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

UNIFI_DATADIR=/usr/lib/unifi/data
UNIFI_RUNDIR=/usr/lib/unifi/run
UNIFI_LOGDIR=/usr/lib/unifi/logs

UNIFI_KEYSTORE_PATH="${UNIFI_DATADIR}/keystore"
UNIFI_KEYSTORE_ALIAS=unifi
UNIFI_KEYSTORE_PASS=aircontrolenterprise


### JVM Options

JVM_OPTS=""
JVM_OPTS="${JVM_OPTS} -Djava.awt.headless=true"
JVM_OPTS="${JVM_OPTS} -Dfile.encoding=UTF-8"
JVM_OPTS="${JVM_OPTS} -Dapple.awt.UIElement=true"
JVM_OPTS="${JVM_OPTS} -Dunifi.core.enabled=false"
JVM_OPTS="${JVM_OPTS} -Dunifi.mongodb.service.enabled=false"
JVM_OPTS="${JVM_OPTS} -Xmx${JVM_MAXHEAP}"
JVM_OPTS="${JVM_OPTS} -XX:+UseParallelGC"
JVM_OPTS="${JVM_OPTS} -XX:+ExitOnOutOfMemoryError"
JVM_OPTS="${JVM_OPTS} -XX:+CrashOnOutOfMemoryError"
JVM_OPTS="${JVM_OPTS} -XX:ErrorFile=/usr/lib/unifi/logs/hs_err_pid%p.log"
JVM_OPTS="${JVM_OPTS} -Xlog:gc:logs/gc.log:time:filecount=2,filesize=5M"
JVM_OPTS="${JVM_OPTS} -Dunifi.datadir=${UNIFI_DATADIR}"
JVM_OPTS="${JVM_OPTS} -Dunifi.rundir=${UNIFI_RUNDIR}"
JVM_OPTS="${JVM_OPTS} -Dunifi.logdir=${UNIFI_LOGDIR}"
JVM_OPTS="${JVM_OPTS} -cp /usr/share/java/commons-daemon.jar:/usr/lib/unifi/lib/ace.jar"
JVM_OPTS="${JVM_OPTS} --add-opens java.base/java.lang=ALL-UNNAMED"
JVM_OPTS="${JVM_OPTS} --add-opens java.base/java.time=ALL-UNNAMED"
JVM_OPTS="${JVM_OPTS} --add-opens java.base/sun.security.util=ALL-UNNAMED"
JVM_OPTS="${JVM_OPTS} --add-opens java.base/java.io=ALL-UNNAMED"
JVM_OPTS="${JVM_OPTS} --add-opens java.rmi/sun.rmi.transport=ALL-UNNAMED"

### User Check

grep unifi /etc/passwd

if [ $? -gt 0 ]; then
  # Unifi user doesn't exist, create it.

  # We can assume UNIFI_UID and UNIFI_GID are defined because they're ENVs in
  # the Dockerfile.

  addgroup \
    --system \
    --gid "$UNIFI_GID" \
    unifi

  adduser \
    --system \
    --home /usr/lib/unifi \
    --no-create-home \
    --uid "$UNIFI_UID" \
    --gid "$UNIFI_GID" \
    --disabled-password \
    --quiet unifi
fi


### Keystore "Stuff" for Secrets

if [ -f "$UNIFI_HTTPS_CACERT_FILE" ]; then
    # Import our CA cert into the trust store

    if [ -z "$UNIFI_HTTPS_CA_ALIAS" ]; then
        UNIFI_HTTPS_CA_ALIAS="custom_ca"
    fi

    keytool -import -trustcacerts \
        -keystore "${UNIFI_KEYSTORE_PATH}" \
        -file "$UNIFI_HTTPS_CACERT_FILE" \
        -alias "$UNIFI_HTTPS_CA_ALIAS" \
        -storepass "$UNIFI_KEYSTORE_PASS" \
        -noprompt
fi

if [ -f "$UNIFI_HTTPS_KEY_FILE" ] && [ "$UNIFI_HTTPS_CERT_FILE" ]; then

    TMP_PFX="${UNIFI_DATADIR}/unifi.pfx"

    # If a temp PKCS12 bundle exists, nuke it
    if [ -f "$TMP_PFX" ]; then
        shred -u "$TMP_PFX"
    fi

    # Pop the keypair into a PFX temporarily
    openssl pkcs12 -export \
        -in "$UNIFI_HTTPS_CERT_FILE" \
        -inkey "$UNIFI_HTTPS_KEY_FILE" \
        -out "$TMP_PFX" \
        -name "$UNIFI_KEYSTORE_ALIAS" \
        -passout "pass:${UNIFI_KEYSTORE_PASS}"

    # Import PFX into Unifi keystore
    keytool -importkeystore \
        -srckeystore "$TMP_PFX" \
        -srcstoretype PKCS12 \
        -srcalias "$UNIFI_KEYSTORE_ALIAS" \
        -srcstorepass "$UNIFI_KEYSTORE_PASS" \
        -destkeystore "$UNIFI_KEYSTORE_PATH" \
        -destalias "$UNIFI_KEYSTORE_ALIAS" \
        -deststorepass "$UNIFI_KEYSTORE_PASS" \
        -noprompt
fi


### Ensure data directories are set up properly

for dpath in "${UNIFI_DATADIR}" "${UNIFI_RUNDIR}" "${UNIFI_LOGDIR}"; do

    mkdir -p "${dpath}"

    chown -R unifi:unifi "${dpath}"
    chmod 750 "${dpath}"

    find "${dpath}" -type d ! -perm 0750 -exec chmod 0750 \{\} \;
    find "${dpath}" -type f ! -perm 0640 -exec chmod 0640 \{\} \;
done


### Start Unifi

cd /usr/lib/unifi
su -s /bin/bash -c "java ${JVM_OPTS} -jar /usr/lib/unifi/lib/ace.jar start" unifi
