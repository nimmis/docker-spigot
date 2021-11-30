FROM nimmis/ubuntu:20.04

MAINTAINER nimmis <kjell.havneskold@gmail.com>

# SPIGOT_HOME         default directory for SPIGOT-server
# SPIGOT_VER          default minecraft version to compile
# SPIGOT_AUTORESTART  set to yes to restart if minecraft stop command is executed
ENV SPIGOT_HOME=/minecraft \
    SPIGOT_VER=latest \
    SPIGOT_AUTORESTART=yes \
    MC_MAXMEM= \
    MC_MINMEM= \
    OTHER_JAVA_OPS= \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

# set default java environment variable
ENV JAVA_VERSION_MAJOR=17 \
    JAVA_TYPE="" \
    JAVA_OPT=hotspot \
    JAVA_HOME=/usr/lib/jvm/default-jvm \
    PATH=${PATH}:/usr/lib/jvm/default-jvm/bin/

# add extra files needed
COPY rootfs /

RUN apt-get update && \

    # upgrade OS
    apt-get -y dist-upgrade && \

    # Make info file about this build
    printf "Build of nimmis/spigot:latest, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` > /etc/BUILDS/spigot && \

    # install application
    apt-get install -y wget git && \

    # Make special user for minecraft to run in
    /usr/sbin/useradd -s /bin/bash -d /minecraft -m minecraft && \

    # Solution of UTF-8 support in docker
    # Reference: https://stackoverflow.com/a/28406007
    apt-get install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen && \

    # get name of dist
    export CNAME=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d = -f 2) && \

    # req. packages
    apt-get install -y wget apt-transport-https gnupg && \

    # get pgp key

    wget https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public && \
    gpg --no-default-keyring --keyring ./adoptopenjdk-keyring.gpg --import public && \
    gpg --no-default-keyring --keyring ./adoptopenjdk-keyring.gpg --export --output adoptopenjdk-archive-keyring.gpg && \
    rm public adoptopenjdk-keyring.gpg && \
    mv adoptopenjdk-archive-keyring.gpg /usr/share/keyrings && \

    # Configure AdoptOpenJDK's apt repository
    echo "deb [signed-by=/usr/share/keyrings/adoptopenjdk-archive-keyring.gpg] https://adoptopenjdk.jfrog.io/adoptopenjdk/deb $CNAME main" | \
      tee /etc/apt/sources.list.d/adoptopenjdk.list && \

    # refresh
    apt-get update && \

    # install
    apt-get install -y adoptopenjdk-$JAVA_VERSION_MAJOR-$JAVA_OPT$JAVA_TYPE && \

    # set compatible home path
    ln -s /usr/lib/jvm/adoptopenjdk-$JAVA_VERSION_MAJOR-$JAVA_OPT$JAVA_TYPE-amd64 /usr/lib/jvm/default-jvm && \




    # remove apt cache from image
    apt-get clean all

# expose minecraft port
EXPOSE 25565


