## Minecraft server SPIGOT on Ubuntu 14.04 with openjava 1.8

This docker image builds and runs the spigot version of minecraft. 

If the spigot.jar is not found in the minecraft directory the system pulls down BuildTool and build a new spigot.jar from the latest
released minecraft.jar

## Why not a precompiled version of spigot included

Due to leagal reasons you can build it but not redistribute the finished jar.

## Starting the container

To run the lastest stable version of this docker image run

	docker run -ti -p 25565:25565 --name minecraft --restart=always -v /data/minecraft:/minecraft -e EULA=true skardoska/spigot

the parameter

	-e EULA=true

The is because Mojang now requires the end user to access their EULA, located at
https://account.mojang.com/documents/minecraft_eula, the be able to start the server.

other parameter

	-p 25565:25565 - Exposes Container port 25565 to the open world
    --name minecraft - Names the container Minecraft
	--restart=always - Automatically starts the container
	-v /data/minecraft:/minecraft - Mounts /data/minecraft host folder to the container

## First time run

This will take a couple of minuters depending on computer and network speed. It will pull down
the latest version on BuildTools and build a spigot.jar from the latest minecraft version.
This is done in numerous steps so be patient. 

If the compilation was successful the server will start in interactive mode. Log in from a minecraft
client to controll that all works. The type

	stop

to drop back to a root shell in the minecraft directory. Edit and add files in /data/minecraft folder on your host machine.


## Future features

This is the initial release of this, more features to come.....

