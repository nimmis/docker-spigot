FROM nimmis/java:openjdk-8-jdk

MAINTAINER nimmis <kjell.havneskold@gmail.com>

#non-interactive installation
ENV DEBIAN_FRONTEND noninteractive

#default directory for SPIGOT-server
ENV SPIGOT_HOME /minecraft

ADD spigot_init.sh /spigot_init.sh

RUN chmod +x /spigot_init.sh

# Make special user for minecraft to run in

RUN useradd -s /bin/bash -d /minecraft -m minecraft

# expose minecraft port
EXPOSE 25565

#set default command
CMD /spigot_init.sh

