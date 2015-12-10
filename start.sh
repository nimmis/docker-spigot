#!/bin/bash
if [ "$EULA" != "true" ]; then
  echo "*****************************************************************"
  echo "*****************************************************************"
  echo "** To be able to run spigot you need to accept minecrafts EULA **"
  echo "** see https://account.mojang.com/documents/minecraft_eula     **"
  echo "** include -e EULA=true on the docker run command              **"
  echo "*****************************************************************"
  echo "*****************************************************************"
  exit
fi

#only build if jar file does not exist
if [ ! -f /$SPIGOT_HOME/spigot.jar ]; then 
  echo "Building spigot jar file, be patient"
  mkdir -p /$SPIGOT_HOME/build
  cd /$SPIGOT_HOME/build
  wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
  HOME=/$SPIGOT_HOME/build java -jar BuildTools.jar
  cp /$SPIGOT_HOME/build/Spigot/Spigot-Server/target/spigot-1.8*.jar /$SPIGOT_HOME/spigot.jar

  #accept eola
  echo "eula=true" > /$SPIGOT_HOME/eula.txt

fi

# chance owner to minecraft
chown -R minecraft.minecraft /$SPIGOT_HOME/


cd /$SPIGOT_HOME/
su - minecraft -c 'java -Xms512M -Xmx1536M -XX:MaxPermSize=128M -jar spigot.jar'

# fallback to root and run shell if spigot don't start/forced exit
bash
