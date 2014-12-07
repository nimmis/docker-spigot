FROM nimmis/ubuntu14.04-jdk-1.7

MAINTAINER nimmis <kjell.havneskold@gmail.com>

#non-interactive installation
ENV DEBIAN_FRONTEND noninteractive

#default directory for SPIGOT-server
ENV SPIGOT_HOME /minecraft

ADD spigot_init.sh /spigot_init.sh

RUN apt-get update && apt-get install -y wget git

# Make special user for minecraft to run in

RUN useradd -s /bin/bash -d /minecraft -m minecraft

# expose minecraft port
EXPOSE 25565

#set default command
CMD /spigot_init.sh

