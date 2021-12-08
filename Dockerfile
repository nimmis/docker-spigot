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
    JAVA_VERSION_MINOR=0.1 \
    JAVA_VERSION_UPDATE=12 \
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
    apt-get install -y wget git jq && \

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

    # create java directory
    mkdir -p /usr/lib/jvm/ && \

    # download jdk and unpack in /usr/lib/jvm
    curl -L https://github.com/adoptium/temurin${JAVA_VERSION_MAJOR}-binaries/releases/download/jdk-${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}%2B${JAVA_VERSION_UPDATE}/OpenJDK${JAVA_VERSION_MAJOR}U-jdk_x64_linux_${JAVA_OPT}_${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}_${JAVA_VERSION_UPDATE}.tar.gz | tar xz -C /usr/lib/jvm/ && \

    # set compatible home path
    ln -s /usr/lib/jvm/jdk-${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}+${JAVA_VERSION_UPDATE} /usr/lib/jvm/default-jvm && \
    ln -s /usr/lib/jvm/default-jvm/bin/java /usr/bin/java && \


    # remove apt cache from image
    apt-get clean all

# expose minecraft port
EXPOSE 25565


