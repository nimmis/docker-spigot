## Minecraft server SPIGIT on Ubuntu 14.04 with openjava 1.8
[![Docker Hub; nimmis/spigot](https://img.shields.io/badge/dockerhub-nimmis%2Fspigot-green.svg)](https://registry.hub.docker.com/u/nimmis/spigot)

This docker image builds and runs the spigot version of minecraft. 

If the spigot.jar is not found in the minecraft directory the system pulls down BuildTool and build a new spigot.jar from the latest
released minecraft.jar

This is a new version of this container where I have removed the script started at the en and set it up to run spigot as a deamon
with the help of supervisord. See my Ubuntu container for a more detailed description of my implementation of an init-process in
ubuntu, see [nimmis/ubuntu](https://hub.docker.com/r/nimmis/ubuntu/)

Whats new is
- selectable spigot version
- do a nice shutdown of the server when the docker stop command is issued
- docker accessable commands to 
   - start/stop/restart the spigot server
   - send console commands to the server
   - look at console output from the server
- 

## Why not a precompiled version of spigot is included

Due to legal reasons you can build it yourself but you can't redistribute the finished jar file.

## Starting the container

To run the lastest stable version of this docker image run

	docker run -d -p 25565:25565 -e EULA=true nimmis/spigot

the parameter

	-e EULA=true

The is because Mojang now requires the end user to access their EULA, located at
https://account.mojang.com/documents/minecraft_eula, the be able to start the server.

the parameter

	-p 25565:25565

tell on witch external port the internal 25565 whould be connected, in this case the same, if
you only type -p 25565 it will connect to a random port on the machine

## Giving the container a name

To make it easier to handle you container you can give it a name instead of the long
number thats normaly give to it, add a

	--name spigot

to the run command to give it the name minecraft, then you can start it easier with

	docker start spigot
	docker stop spigot

## First time run

This will take a couple of minuters depending on computer and network speed. It will pull down
the selected version on BuildTools and build a spigot.jar from the selected minecraft version.
This is done in numerous steps so be patient. 

you can follow the output from the compilation with then command (assume that you given the cotainer
the name spigot)

	docker logs -f spigot

Then the compilation is completed the server will start and you will see somethine like


	2016-04-09 12:37:45,392 CRIT Set uid to user 0
	*** Started processes via Supervisor......
	crond                            RUNNING    pid 28, uptime 0:00:04
	spigot                           RUNNING    pid 29, uptime 0:00:04
	syslog-ng                        RUNNING    pid 27, uptime 0:00:04


you can then exit from the log with CTRL-C

### Selecting version to compile

If you don't specify it will always comple the latest version but if you want a specific version you
can specifiy it by adding

	-e SPIGOT_VER <version>

where <version> is the version you would like to use, to build it with version 1.8 add

	-e SPIGOT_VER 1.8

to the docker run line.

#### versions avaliable

The following version is atm avaliable 1.8, 1.8.3, 1.8.7, 1.8.8, 1.9, 1.9.2 and latest. Please check
the webpage for [BuildTools](https://www.spigotmc.org/wiki/buildtools/#versions) to get the latest information. 
 
## look at the last output from the spigot server

To get an output of the latest events from the spigot server type

	docker exec spigot mc_log

and you will see the last 10 lines from the output, this is what you will see after startup

	Abort with CTRL-C
	[13:02:15 INFO]: Zombie Aggressive Towards Villager: true
	[13:02:15 INFO]: Experience Merge Radius: 3.0
	[13:02:15 INFO]: Preparing start region for level 0 (Seed: 506255305130990210)
	[13:02:16 INFO]: Preparing spawn area: 22%
	[13:02:17 INFO]: Preparing spawn area: 99%
	[13:02:17 INFO]: Preparing start region for level 1 (Seed: 506255305130990210)
	[13:02:18 INFO]: Preparing spawn area: 95%
	[13:02:18 INFO]: Preparing start region for level 2 (Seed: 506255305130990210)
	[13:02:18 INFO]: Server permissions file permissions.yml is empty, ignoring it
	[13:02:18 INFO]: Done (3.650s)! For help, type "help" or "?"

It will continue to output everything from the console until you press CTRL-C 

## sending commands to the server console

You don't need to have an interactive container to be able to send commands to the console. To send
a command to set the time to day you type

	docker exec spigot mc_send "time set day"

If this was the first command issued after a start the output should look like

	[13:02:15 INFO]: Zombie Aggressive Towards Villager: true
	[13:02:15 INFO]: Experience Merge Radius: 3.0
	[13:02:15 INFO]: Preparing start region for level 0 (Seed: 506255305130990210)
	[13:02:16 INFO]: Preparing spawn area: 22%
	[13:02:17 INFO]: Preparing spawn area: 99%
	[13:02:17 INFO]: Preparing start region for level 1 (Seed: 506255305130990210)
	[13:02:18 INFO]: Preparing spawn area: 95%
	[13:02:18 INFO]: Preparing start region for level 2 (Seed: 506255305130990210)
	[13:02:18 INFO]: Server permissions file permissions.yml is empty, ignoring it
	[13:02:18 INFO]: Done (3.650s)! For help, type "help" or "?"
	[13:12:35 INFO]: Set the time to 1000

It will continue to output everything from the console until you press CTRL-C

## starting and stopping the server

To stop the server but not the container do

	docker exec spigot mc_stop

To start it after beeing stopped do

	docker exec spigot mc_start

Finaly to restart it do

	docker exec spiot mc_restart

## stopping the container

When the container is stopped with the command

	docker stop spigot

the spigot server is shutdown nicely with a console stop command to give it time to save everything before
stopping the container. If you look in the output from the server this show

	[13:01:51 INFO]: Stopping the server
	[13:01:51 INFO]: Stopping server
	[13:01:51 INFO]: Saving players
	[13:01:51 INFO]: nimmis lost connection: Server closed
	[13:01:51 INFO]: nimmis left the game.
	[13:01:51 INFO]: Saving worlds
	[13:01:51 INFO]: Saving chunks for level 'world'/Overworld
	[13:01:51 INFO]: Saving chunks for level 'world_nether'/Nether
	[13:01:51 INFO]: Saving chunks for level 'world_the_end'/The End

## Having the minecraft files on the host machine

If you delete the container all your filer in minecraft will be gone. To save them where it's
easier to edit and do a backup of the files you can attach a directory from the host machine
(where you run the docker command) and attach it to the local file system in the container.
The syntax for it is

	-v /host/path/to/dir:/container/path/to/dir

To attach the minecraft directory in the container to directory /home/nimmis/mc-srv you add

	-v /home/nimmis/mc-srv:/minecraft

## Future features

- automatic backup
- plugins
- more....
