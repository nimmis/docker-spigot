## Minecraft server SPIGOT on Ubuntu 20.04 with OpenJDK 11/16/17

![](https://img.shields.io/docker/pulls/nimmis/spigot?style=flat-square)


**NOW works with Minecraft 1.18**

This is a major change in logic to build the correct version of spigot so some combination of conditions may not compile correctly. Please make an issue so I can correct it. There will be another build shortly with another feature

Java bug on version 1.17 with 1 core add **-e OTHER_JAVA_OPTS=-Djava.util.concurrent.ForkJoinPool.common.parallelism=1** as workaround

This docker image builds and runs the spigot version of minecraft. 

If the spigot.jar is not found in the minecraft directory the system pulls down BuildTool and builds a new spigot.jar from the latest
released minecraft.jar

Each time the container is started the presence of the file /minecraft/spigot.jar, if the file is missing a build of spigot.jar is started.

The spigot daemon is started with supervisord, see my Ubuntu container for a more detailed description of my implementation of an init-process in ubuntu, see [nimmis/ubuntu](https://hub.docker.com/r/nimmis/ubuntu/)

What's new is

- Possibility to change spigot versions i running containers
- Detects version if mc-directory already has a precompiled version active
- Adjust java version depending of MC version, downloads additional java version if needed
- Support for Minecraft version 1.18

## Why not a precompiled version of spigot is included

Due to legal reasons you can build it yourself but you can't redistribute the finished jar file.

## Starting the container

To run the latest stable version of this docker image run

	docker run -d -p 25565:25565 -e EULA=true nimmis/spigot

the parameter

	-e EULA=true

The is because Mojang now requires the end user to access their EULA, located at
https://account.mojang.com/documents/minecraft_eula, the be able to start the server.

the parameter

	-p 25565:25565

specifies on which external port the internal 25565 should be connected, in this case the same.
If you only type -p 25565 it will connect to a random port on the machine.

## Giving the container a name

To make it easier to handle you container you can give it a name instead of the long
number that's normally given to it, add a

	--name spigot

to the run command to give it the name minecraft, then you can start it easier with

	docker start spigot
	docker stop spigot

## First time run

This will take a couple of minutes depending on computer and network speed. It will pull down
the selected version on BuildTools and build a spigot.jar from the selected minecraft version.
This is done in numerous steps so be patient. 

You can follow the output from the compilation with this command (assuming that you gave the container
the name spigot)

	docker logs -f spigot
	*** open logfile
	*** Run files in /etc/my_runonce/
	*** Running /etc/my_runonce/00_dump_info.sh...
	Build of nimmis/spigot:latest, date: 2021-12-06T12:54:26Z
	Build of nimmis/ubuntu:20.04, date: 2021-07-04T09:06:36Z
	*** Running /etc/my_runonce/50_set_timezone...
	timezone not set, trying to autodetect
	external ip is 95.192.***.***
	timezone should be Europe/Stockholm
	setting timezone to Europe/Stockholm
	*** Running /etc/my_runonce/90_autorestart...
	*** Run files in /etc/my_runalways/
	*** Running /etc/my_runalways/00_minecraft_owner...
	missmatch between directory owner and minecraft user
	Changed owner of minecraft to UID 0
	*** Running /etc/my_runalways/10_set_mc_version...
	*** Running /etc/my_runalways/50_do_build_spigot...
	checking 1.18
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
	                                 Dload  Upload   Total   Spent    Left  Speed
	100  135k  100  135k    0     0   436k      0 --:--:-- --:--:-- --:--:--  434k
	Setting version to 1.18
	set java version to 17
	Building spigot version (1.18) jar file, be patient



Once the compilation completes the server will start and you will see something like

	Success! Everything completed successfully. Copying final .jar files now.
	Copying spigot-1.18-R0.1-SNAPSHOT-bootstrap.jar to /build-mc/./spigot-1.18.jar
  	Saved as ./spigot-1.18.jar
	Successfull build of spigot version 1.18
	Setting 1.18 as current spigot version
	*** Running /etc/my_runalways/85_fix_startsh...
	start.sh missing, creating link for /minecraft/start.sh
	*** Running /etc/my_runalways/90_eula...
	*** Booting supervisor daemon...
	*** Supervisor started as PID 781
	*** Started processes via Supervisor......
	crond                            RUNNING   pid 783, uptime 0:00:04
	spigot                           RUNNING   pid 784, uptime 0:00:04
	syslog-ng                        RUNNING   pid 785, uptime 0:00:03

you can then exit from the log with CTRL-C

### Selecting version to compile

You can now change the minecraft version after you started the container the first time.

#### defining version on first start

If you don't specify this parameter it will check the minecraft directory in the container to see if there is a previous compiled version linked. If so the container will use that version.

If no version of spigot is linked (like first time) it will always compile the latest version but if you want a specific version you can specify it by adding

	-e SPIGOT_VER=<version>

where <version> is the version you would like to use, to build it with version 1.18 add

	-e SPIGOT_VER=1.18

to the docker run line.

#### change version in a running container

There is a command to change minecraft version in a running container

	docker exec -it spigot set_mc_ver <version>

when the command is executed it will check if there is a compiled version already in the minecraft folder, if not it will build it.

It first stops the running minecraft, changes java version if needed (download if missing), compiles a new spigot if needed and then starts minecraft again.

It is not recommended to downgrade version as the world-information is not backwards compatible.

#### versions available

Please check
the web page for [BuildTools](https://www.spigotmc.org/wiki/buildtools/#versions) to get the latest information. 

### setup memory to use

There are two environment variables to set maximum and initial memory for spigot.

#### MC_MAXMEM

Sets the maximum memory to use <size>m for MB or <size>g for GB, defaulting to 1 GB. To set the maximum memory to 2 GB add this environment variable

    -e MC_MAXMEM=2g

#### MC_MINMEM

Sets the initial memory reservation used, use <size>m for MB or <size>g for GB, if this parameter is not set, it is set to MC_MAXMEM. To set the initial size to 512 MB

    -e MC_MINMEM=512m


#### SPIGOT_AUTORESTART

This variable controls the behavior of the container when the **stop** command is issued inside minecraft

	-e SPIGOT_AUTORESTART=yes
   
Which is the default behavior and does not need to be specified, the minecraft server will autostart if the **stop** command is issued.

	-e SPIGOT_AUTORESTART=no
	
If the **stop** command is issued the minecraft server will stay down until the container is restarted or the command **mc_start** is issued

#### OTHER_JAVA_OPS

Allows adding other Java options when starting minecraft

	-e OTHER_JAVA_OPS=



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

### using the minecraft op command 

To make yourself operator in the game use **mc_send** command, for example give the user **myuser** op use the command.

	docker exec spigot mc_send op myuser

### using the minecraft stop command

By default the minecraft server will automatically restart on a **stop** inside the minecraft application. You can override this behavior by using

	-e SPIGOT_AUTORESTART=no

This will prevent the server automatically restarting and minecraft has to be started again with the **mc_start** command


## starting and stopping the server

To stop the server but not the container do

	docker exec spigot mc_stop

To start it after being stopped do

	docker exec spigot mc_start

Finally to restart it do

	docker exec spigot mc_restart

## stopping the container

When the container is stopped with the command

	docker stop spigot

the spigot server is shutdown nicely with a console stop command to give it time to save everything before
stopping the container. If you look in the output from the server you will see something like

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

If you delete the container all your files in minecraft will be gone. To save them where it's
easier to edit and do a backup of the files you can attach a directory from the host machine
(where you run the docker command) and attach it to the local file system in the container.
The syntax for it is

	-v /host/path/to/dir:/container/path/to/dir

To attach the minecraft directory in the container to directory /home/nimmis/mc-srv you add

	-v /home/nimmis/mc-srv:/minecraft

### problems with external mounted volumes

When a external volume is mounted the UID of the owner of the volume may not match the UID of the minecraft user (1000). This can result in problems with write/read access to the files. 

To address this problem a check is done between UID of the owner of /minecraft and the UID of the user minecraft. If there is a mismatch the UID of the minecraft user is changed to match the UID of the directory.

If you don't want to do this and want to manually set the UID of the minecraft user there is a variable named SPIGOT_UID which defines the minecraft user UID, adding

	-e SPIGOT_UID=1132

sets the minecraft user UID to 1132.

## Other commands available to container

The syntax is

	docker exec -ti <spigot container name> <command> <paramaters>

### command: get_mc_versions

If you get minecraft version not found and it is a version released after to started the container the first time. You need to update the list of available versions, do 

	docker exec -it <spigotverson> get_mc_versions

and you should get an output simular to

	docker exec -it spigot get_mc_versions
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
	100  135k  100  135k    0     0   498k      0 --:--:-- --:--:-- --:--:--  498k

and the versionlist is updated.

## Old versions news

- Updated java version to 17 which is a LTS version
- Adopt moved to Eclipe Foundation and changed name to Adoptium
- Updated java version to 16 to compile minecraft 1.17
- Switched to Adopt OpenJDK
- Fix for problem introduced during fall of 2017 for both Windows 10 and MacOS versions of docker, failed to build new versions of spigot 
- Autodetection of timezone if container has access to internet
- adjust minecraft user UID to match mounted volume
- selectable memory size for the Java process
- selectable spigot version
- do a nice shutdown of the server when the docker stop command is issued
- docker accessible commands to 
   - start/stop/restart the spigot server
   - send console commands to the server
   - look at console output from the server

## Issues

If you have any problems with or questions about this image, please contact us by submitting a ticket through a [GitHub issue](https://github.com/nimmis/docker-spigot/issues "GitHub issue")

1. Look to see if someone already filled the bug, if not add a new one.
2. Add a good title and description with the following information.
 - if possible an copy of the output from **cat /etc/BUILDS/*** from inside the container
 - any logs relevant for the problem
 - how the container was started (flags, environment variables, mounted volumes etc)
 - any other information that can be helpful

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

## Future features

- automatic backup
- plugins
- more....

