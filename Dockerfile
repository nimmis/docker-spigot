FROM nimmis/java:openjdk-8-jdk

MAINTAINER nimmis <kjell.havneskold@gmail.com>

# SPIGOT_HOME default directory for SPIGOT-server
# SPIGOT_VER  default minecraft version to compile
ENV SPIGOT_HOME=/minecraft \
    SPIGOT_VER=latest

# add extra files needed
COPY rootfs /

# add overviewer repository & key
RUN echo "deb http://overviewer.org/debian ./" >> /etc/apt/sources.list && curl http://overviewer.org/debian/overviewer.gpg.asc | apt-key add -

RUN apt-get update && \

    # upgrade OS
    apt-get -y dist-upgrade && \

    # Make info file about this build
    printf "Build of nimmis/spigot:latest, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` > /etc/BUILDS/spigot && \

    # install applications, including nginx & overviewer
    apt-get install -y wget git nginx minecraft-overviewer && \

    # Make special user for minecraft to run in
    /usr/sbin/useradd -s /bin/bash -d /minecraft -m minecraft && \

    # remove apt cache from image
    apt-get clean all

# expose minecraft port
EXPOSE 25565

# expose nginx port for overviewer
EXPOSE 80
