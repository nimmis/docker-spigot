FROM nimmis/java:openjdk-8-jdk

MAINTAINER nimmis <kjell.havneskold@gmail.com>

#default directory for SPIGOT-server
ENV SPIGOT_HOME /minecraft

#default version 
ENV SPIGOT_VER latest

# add extra files needed
COPY rootfs /

# add overviewer repository & key
RUN echo "deb http://overviewer.org/debian ./" >> /etc/apt/sources.list && curl http://overviewer.org/debian/overviewer.gpg.asc | sudo apt-key add -

# add some needed commands, including nginx & overviewer
RUN apt-get update && apt-get install -y wget git nginx minecraft-overviewer && apt-get clean all

# Make special user for minecraft & overviewer to run in
RUN useradd -s /bin/bash -d /minecraft -m minecraft

# expose minecraft port
EXPOSE 25565

# expose nginx port for overviewer
EXPOSE 80
